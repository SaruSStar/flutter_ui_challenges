import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui_challenges/core/data/models/survey.dart';
import 'package:flutter_ui_challenges/core/presentation/res/functions.dart';
import 'package:flutter_ui_challenges/core/presentation/widgets/survey_widget.dart';
import 'package:flutter_ui_challenges/features/announcements/data/model/announcement.dart';
import 'package:flutter_ui_challenges/features/announcements/widgets/announcement_slider.dart';
import 'package:flutter_ui_challenges/features/auth/data/model/user.dart';
import 'package:flutter_ui_challenges/features/auth/data/model/user_repository.dart';
import 'package:flutter_ui_challenges/src/pages/invitation/inauth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class NewHomePage extends StatefulWidget {
  @override
  _NewHomePageState createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage>
    with SingleTickerProviderStateMixin {
  RemoteConfig remoteConfig;
  bool dialogShowing;
  bool showNewUiDialog;
  List<Announcement> announcements;
  SurveyItem survey;
  AnimationController _animationController;
  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    dialogShowing = false;
    showNewUiDialog = false;
    announcements = [];
    _getRemoteConfig();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  _getRemoteConfig() async {
    if (remoteConfig == null) remoteConfig = await RemoteConfig.instance;
    final Map<String, dynamic> defaults = {
      "news": "[]",
      "survey": {},
    };
    await remoteConfig.setDefaults(defaults);
    await remoteConfig.fetch(expiration: const Duration(hours: 12));
    await remoteConfig.activateFetched();
    final String value = remoteConfig.getString('news');
    final String surval = remoteConfig.getString('survey');
    setState(() {
      announcements = List<Map<String, dynamic>>.from(json.decode(value))
          .map((data) => Announcement.fromMap(data))
          .toList();
      survey =
          SurveyItem.fromMap(Map<String, dynamic>.from(json.decode(surval)));
    });
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    return Scaffold(
      appBar: customAppBar(context: context),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 16.0),
          if (announcements.length > 0) ...[
            AnnouncementSlider(news: announcements),
            const SizedBox(height: 16.0),
          ],
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                CategoryItem(
                  title: "UI Challenges",
                  onPressed: () =>
                      Navigator.pushNamed(context, 'challenge_home'),
                ),
                const SizedBox(height: 10.0),
                CategoryItem(
                  icon: Icon(
                    FontAwesomeIcons.user,
                    color: Colors.indigo,
                  ),
                  title: "Profile",
                  onPressed: () {
                    (Provider.of<UserRepository>(context).user != null)
                        ? Navigator.pushNamed(context, "profile")
                        : Navigator.pushNamed(context, 'auth_home');
                  },
                ),
                const SizedBox(height: 10.0),
                CategoryItem(
                  title: "About",
                  icon: Icon(
                    FontAwesomeIcons.infoCircle,
                    color: Colors.red,
                  ),
                  onPressed: () => Navigator.pushNamed(context, 'about'),
                ),
                if (survey != null &&
                    user != null &&
                    !user.surveys.contains(survey?.id)) ...[
                  const SizedBox(height: 10.0),
                  SurveyWidget(survey: survey),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final TextStyle buttonText = boldText.copyWith(
    fontSize: 16.0,
  );
  final Function onPressed;
  final String title;
  final Widget icon;

  CategoryItem({
    Key key,
    this.onPressed,
    this.title,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      highlightElevation: 0,
      elevation: 0,
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: <Widget>[
          if (icon != null) ...[
            icon,
            const SizedBox(width: 10.0),
          ],
          Text(
            title,
            style: buttonText,
          ),
          Spacer(),
          Icon(Icons.keyboard_arrow_right),
        ],
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      onPressed: onPressed,
    );
  }
}
