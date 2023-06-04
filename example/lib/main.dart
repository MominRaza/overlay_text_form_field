import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:overlay_text_form_field/overlay_text_form_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OverlayTextFormField Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) =>
                const MyHomePage(title: 'OverlayTextFormField Example'),
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = TextEditingController();

  final users = [
    {
      'name': 'Momin Raza',
      'handle': 'momin',
    },
    {
      'name': 'Zaid Raza',
      'handle': 'zaid',
    },
    {
      'name': 'Mohd Uzam',
      'handle': 'uzam',
    },
    {
      'name': 'Hammad Raza',
      'handle': 'hammad',
    },
  ];

  final tags = [
    'Superman',
    'Batman',
    'WonderWoman',
    'Aquaman',
    'Cyborg',
    'TheFlash'
  ];

  Widget overlayMentionBuilder(query, onOverlaySelect) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return (users[index]['handle'] as String).toLowerCase().contains(query)
            ? ListTile(
                visualDensity: VisualDensity.compact,
                leading: const CircleAvatar(),
                title: Text(users[index]['name'] ?? ''),
                subtitle: Text('@${users[index]['handle']}'),
                onTap: () => onOverlaySelect(users[index]['handle']),
              )
            : const SizedBox();
      },
      itemCount: users.length,
    );
  }

  Widget overlayTagBuilder(query, onOverlaySelect) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return (tags[index]).toLowerCase().contains(query)
            ? ListTile(
                visualDensity: VisualDensity.compact,
                title: Text('#${tags[index]}'),
                onTap: () => onOverlaySelect(tags[index]),
              )
            : const SizedBox();
      },
      itemCount: tags.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: OverlayTextFormField(
          controller: controller,
          overlayMentionBuilder: overlayMentionBuilder,
          overlayTagBuilder: overlayTagBuilder,
          overlayAboveTextField: true,
        ),
      ),
    );
  }
}
