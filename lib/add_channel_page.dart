import 'package:flutter/material.dart';
import 'package:algolia/algolia.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddChannel extends StatefulWidget {
  @override
  _AddChannelState createState() => _AddChannelState();
}

class _AddChannelState extends State<AddChannel> {
  final algolia = Algolia.init(
    applicationId: DotEnv().env['APPLICATION_ID'],
    apiKey: DotEnv().env['API_KEY'],
  );
  final id = TextEditingController();
  final name = TextEditingController();
  final numRegisters = TextEditingController();

  @override
  void dispose() {
    final controllers = [id, name, numRegisters];
    controllers.forEach(
      (cnt) => cnt.dispose(),
    );

    super.dispose();
  }

  bool _canParseStringToInt(String text) {
    bool canParse = false;

    try {
      int.parse(text);
      canParse = true;
    } catch (e) {
      canParse = false;
    }

    return canParse;
  }

  Future<bool> _confirmDialog({
    String titleText,
    String contentText,
    String doneText,
  }) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titleText),
          content: Text(contentText),
          actions: [
            FlatButton(
              child: Text(
                'キャンセル',
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text(
                doneText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
  }

  Future _addChannel() async {
    final newData = {
      'id': int.parse(id.text),
      'name': name.text,
      'numRegisters': int.parse(numRegisters.text),
    };
    await algolia.instance.index('sample').addObject(newData);
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('チャンネルを追加'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  autofocus: true,
                  controller: id,
                  decoration: InputDecoration(
                    labelText: 'ID',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.trim().isEmpty) {
                      return '入力してください';
                    }

                    if (!_canParseStringToInt(value.trim())) {
                      return '数字を入力してください';
                    }

                    return null;
                  },
                ),
                TextFormField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: 'チャンネル名',
                  ),
                  validator: (value) {
                    if (value.trim().isEmpty) {
                      return '入力してください';
                    }

                    if (value.length > 50) {
                      return '文字数を減らしてください';
                    }

                    return null;
                  },
                ),
                TextFormField(
                  controller: numRegisters,
                  decoration: InputDecoration(
                    labelText: '登録者数',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.trim().isEmpty) {
                      return '入力してください';
                    }

                    if (!_canParseStringToInt(value.trim())) {
                      return '数字を入力してください';
                    }

                    return null;
                  },
                ),
                SizedBox(height: 30),
                ButtonTheme(
                  minWidth: double.infinity,
                  height: 44,
                  child: FlatButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: Text(
                      '登録する',
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState.validate()) return;

                      final confirm = await _confirmDialog(
                        titleText: '登録する',
                        contentText: '入力した内容で登録します。',
                        doneText: '登録する',
                      );

                      if (!confirm) return;

                      try {
                        await this._addChannel();

                        Navigator.pop(context);
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('エラー'),
                              content: Text(e.toString()),
                              actions: [
                                FlatButton(
                                  child: Text(
                                    'OK',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
