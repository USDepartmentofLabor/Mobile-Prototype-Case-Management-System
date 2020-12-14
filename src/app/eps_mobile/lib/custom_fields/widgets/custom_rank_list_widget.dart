import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class CustomRankListWidget extends StatefulWidget {
  CustomRankListWidget({
    Key key,
    this.labelText,
    this.padding,
    this.height,
    this.choices,
  }) : super(key: key);

  final String labelText;
  final EdgeInsetsGeometry padding;
  final double height;
  final List<Tuple2<int, String>> choices;

  final _CustomRankListWidgetState _widgetState =
      new _CustomRankListWidgetState();

  @override
  _CustomRankListWidgetState createState() {
    return getState();
  }

  _CustomRankListWidgetState getState() {
    return _widgetState;
  }

  dynamic getValue() {
    var data = getState().getValues();
    var rtn = [];
    for (var item in data) {
      rtn.add({
        "id": item.item2,
        "rank": item.item1,
      });
    }
    return rtn;
  }
}

class _CustomRankListWidgetState extends State<CustomRankListWidget> {
  List<RankListItemWidget> _orderables;

  void initState() {
    super.initState();
    _orderables = List<RankListItemWidget>();
    for (var choice in widget.choices) {
      _orderables.add(
        RankListItemWidget(
          customWidgetString: choice.item2,
          key: ValueKey(choice.item1),
          id: choice.item1,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: widget.padding,
      child: ReorderableListView(
        header: Text(widget.labelText),
        scrollDirection: Axis.vertical,
        children: _orderables,
        onReorder: _onReorder,
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(
      () {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final Widget item = _orderables.removeAt(oldIndex);
        _orderables.insert(newIndex, item);
      },
    );
  }

  List<Tuple2<int, int>> getValues() {
    List<Tuple2<int, int>> values = List<Tuple2<int, int>>();
    var i = 0;
    for (var choice in _orderables) {
      values.add(Tuple2<int, int>(
        i + 1,
        choice.id,
      ));
      i++;
    }
    return values;
  }
}

class RankListItemWidget extends StatelessWidget {
  final String customWidgetString;
  final Key key;
  final int id;

  const RankListItemWidget({this.key, this.id, this.customWidgetString})
      : super(key: key);

  Widget _widget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: SizedBox(
        height: 50.0,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(width: 1.0, color: Colors.black),
              left: BorderSide(width: 1.0, color: Colors.black),
              right: BorderSide(width: 1.0, color: Colors.black),
              bottom: BorderSide(width: 1.0, color: Colors.black),
            ),
          ),
          child: Text(
            customWidgetString,
            key: key,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _widget(context);
  }
}
