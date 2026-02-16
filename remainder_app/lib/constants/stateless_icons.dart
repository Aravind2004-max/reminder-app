import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RefreshIcon extends StatefulWidget {
  final Future<void> Function() anyFunction;
  const RefreshIcon({super.key, required this.anyFunction});

  @override
  State<RefreshIcon> createState() => _RefreshIconState();
}

class _RefreshIconState extends State<RefreshIcon> {
  bool _isLoading = false;

  Future<bool> refresher() async {
    try {
      await widget.anyFunction();
      return false;
    } catch (err) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        setState(() {
          _isLoading = true;
        });
        try {
          await Future.delayed(const Duration(seconds: 3));
          _isLoading = await refresher();
        } catch (err) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: _isLoading
          ? Lottie.asset(
              'assets/animations/refresh_indicator.json',
              width: 50,
              repeat: true,
            )
          : Icon(Icons.refresh, color: Colors.black),
    );
  }
}
