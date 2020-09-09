import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:algolia/algolia.dart';
import 'package:flutter_algolia/channel.dart';

void main() async {
  await DotEnv().load('.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Algolia algolia = Algolia.init(
    applicationId: DotEnv().env['APPLICATION_ID'],
    apiKey: DotEnv().env['API_KEY'],
  );
  List<Channel> channels = [];
  bool isLoading = false;
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future searchChannel({String text}) async {
    if (text.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();

    AlgoliaQuery query = algolia.instance.index('sample').search(text);
    AlgoliaQuerySnapshot snap = await query.getObjects();
    final channels = snap.hits.map((hit) => Channel(hit.data)).toList();
    setState(
      () {
        this.channels = channels;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Form(
                child: Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        controller: searchController,
                        cursorColor: Colors.white,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '検索',
                          hintStyle: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onFieldSubmitted: (_) async {
                          this.searchChannel(text: searchController.text);
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        this.searchChannel(text: searchController.text);
                      },
                    ),
                  ],
                ),
              ),
            ),
            body: ListView.builder(
              itemCount: this.channels.length,
              itemBuilder: (context, index) {
                final listTiles = this.channels.map(
                  (channel) {
                    return ListTile(
                      title: Text(channel.name),
                      subtitle: Text('${channel.numRegisters} registers'),
                    );
                  },
                ).toList();
                return listTiles[index];
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
          ),
        ),
        this.isLoading
            ? Container(
                color: Colors.white.withOpacity(0.4),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : SizedBox(),
      ],
    );
  }
}
