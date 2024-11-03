import 'package:flutter/cupertino.dart';
import 'package:cupertino_onboarding/cupertino_onboarding.dart';
import 'package:flutter/material.dart';
import 'package:good/auth.dart';


class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

 

  @override
  Widget build(BuildContext context) {
    return CupertinoOnboarding(
      pages: [
        WhatsNewPage(
          title: const Text("Welcome to Good Deed"),
          features: [
            WhatsNewFeature(
              icon: Icon(
                CupertinoIcons.heart,
                color: CupertinoColors.systemRed.resolveFrom(context),
              ),
              title: const Text('Support NGOs'),
              description: const Text(
                'Find and support NGOs easily with verified details and trusted connections.',
              ),
            ),
            WhatsNewFeature(
              icon: Icon(
                CupertinoIcons.money_dollar_circle,
                color: CupertinoColors.systemGreen.resolveFrom(context),
              ),
              title: const Text('Direct Donations'),
              description: const Text(
                "Donate directly and transparently to people or causes you care about.",
              ),
            ),
          ],
        ),
        const CupertinoOnboardingPage(
          title: Text('Connect with Communities'),
          body: Icon(
            CupertinoIcons.person_2,
            size: 200,
          ),
        ),
        CupertinoOnboardingPage(
          title: const Text('Choose Your Role'),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton.filled(
                child: const Text('I am an NGO'),
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthScreen())),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthScreen())),
                color: CupertinoColors.systemGrey,
                child: const Text('I am a Donor'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}