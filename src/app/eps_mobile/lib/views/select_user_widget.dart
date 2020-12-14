import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/permission_values.dart';
import 'package:eps_mobile/models/user.dart';
import 'package:eps_mobile/queries/user_queries.dart';
import 'package:flutter/material.dart';

class SelectUserWidget extends StatefulWidget {
  SelectUserWidget({
    Key key,
    this.epsState,
    this.getUserWithThesePermissions,
    this.allowUnassigned,
  }) : super(key: key);

  final EpsState epsState;
  final List<PermissionValues> getUserWithThesePermissions;
  final bool allowUnassigned;

  final _SelectUserWidgetState _selectUserWidgetState =
      new _SelectUserWidgetState();

  @override
  _SelectUserWidgetState createState() {
    return getState();
  }

  _SelectUserWidgetState getState() {
    return _selectUserWidgetState;
  }
}

class _SelectUserWidgetState extends State<SelectUserWidget> {
  // vars
  List<User> _users;
  User selectedUser;

  User getSelectedUser() {
    return this.selectedUser;
  }

  // init
  @override
  void initState() {
    super.initState();

    selectedUser = null;

    UserQueries.getUsersWithPermissions(
      widget.epsState.database.database,
      widget.getUserWithThesePermissions,
    ).then((value) {
      setState(() {
        if (value.length > 0) {
          this._users = value;
        } else {
          this._users = List<User>();
        }
      });
    }).then((value) {
      this._users.add(widget.epsState.user);
      if (widget.allowUnassigned) {
        addUnassignedUser();
      }
    });
  }

  void addUnassignedUser() {
    var unassignedUser = User();
    unassignedUser.id = -1;
    unassignedUser.name = 'Unassigned';
    unassignedUser.email = 'N/A';
    setState(() {
      this._users.add(
            unassignedUser,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Select User'),
        ),
        body: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    var widgets = new List<Widget>();
    for (var x in this._users) {
      widgets.add(buildRow(context, x));
    }
    return ListView(
      children: widgets,
    );
  }

  Widget buildRow(
    BuildContext context,
    User user,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
      child: GestureDetector(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 1.0),
                  child: Text(
                    user.name.substring(
                        0, user.name.length > 30 ? 29 : user.name.length),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 22.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(4.0, 1.0, 1.0, 1.0),
                  child: Text(
                    user.email.substring(
                        0, user.email.length > 50 ? 49 : user.email.length),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          setState(() {
            selectedUser = user;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
