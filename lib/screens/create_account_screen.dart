import 'dart:async';

import 'package:flutter/material.dart';

import '../widgets/header.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  String username = '';

  void submit() {
    final form = _formKey.currentState;

    setState(() {
      isSubmitting = true;
    });

    if (form!.validate()) {
      form.save();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome $username! One second while we set you up..'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );

      Timer(
        const Duration(seconds: 2),
        () {
          setState(() {
            isSubmitting = false;
          });

          Navigator.pop(context, username);
        },
      );
    } else {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: 'Setup your Profile',
        removeBackButton: true,
      ),
      body: ListView(
        children: [
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 25),
                child: Center(
                  child: Text(
                    'Create a username',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.always,
                  child: TextFormField(
                    validator: (val) {
                      if (val!.trim().length < 3 || val.isEmpty) {
                        return 'Username too short';
                      } else if (val.trim().length > 12) {
                        return 'Username too long';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (val) => username = val!,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Username',
                      labelStyle: TextStyle(
                        fontSize: 15,
                      ),
                      hintText: 'Must be at least 3 characters',
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: !isSubmitting ? submit : () {},
                child: Container(
                  height: 50,
                  width: 350,
                  decoration: BoxDecoration(
                    color: !isSubmitting ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Center(
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
