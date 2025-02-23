import 'package:flashcardstudyapplication/core/themes/app_theme.dart';
import 'package:flutter/material.dart';

class MyDeckToolBar extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback onSeachNewDecks;
  final VoidCallback onCreateDeck;
  final bool isSearchingNewDecks;
  const MyDeckToolBar({
    Key? key,
    this.isAdmin = false,
    required this.onCreateDeck,
    required this.onSeachNewDecks,
    required this.isSearchingNewDecks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double height = 50;
    final double width = 100;

    final textColor = Theme.of(context).colorScheme.primary;

    var children = [
      Expanded(
        child: Container(
          padding: EdgeInsets.all(5),
          alignment: Alignment.center,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: isSearchingNewDecks ? onSeachNewDecks : onSeachNewDecks,
            child: Text(
              'Deck    Pool',
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor),
            ),
          ),
        ),
      ),
      SizedBox(
        height: height,
        child: VerticalDivider(
          color: textColor,
          indent: 10,
          endIndent: 10,
          thickness: 2,
        ),
      ),
      Expanded(
        child: Container(
          padding: EdgeInsets.all(5),
          alignment: Alignment.center,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onCreateDeck,
            child: Text(
              'Create Deck',
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor),
            ),
          ),
        ),
      ),
      if (isAdmin) ...[
        SizedBox(
          height: height,
          child: VerticalDivider(
            color: textColor,
            indent: 10,
            endIndent: 10,
            thickness: 2,
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.center,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/admin');
              },
              child: Text(
                'Admin Panel',
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor),
              ),
            ),
          ),
        ),
        SizedBox(
          height: height,
          child: VerticalDivider(
            color: textColor,
            indent: 10,
            endIndent: 10,
            thickness: 2,
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.center,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.pushNamed(context, '/collections');
              },
              child: Text('Collections',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor)),
            ),
          ),
        ),
      ],
    ];

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.tertiary,
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
