import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service & Privacy Policy, Effective Date: September 25, 2025'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '''

          This page outlines the Terms of Service ("Terms") and the Privacy Policy for the Flashlight App ("the App"). By downloading, installing, or using the App, you agree to be bound by these Terms and consent to our Privacy Policy.

Terms of Service
1. Health and Safety Warning: Seizure Risk

This App includes a "strobe" feature that produces flashing lights. Flashing lights can trigger epileptic seizures in individuals with photosensitive epilepsy.

!! WARNING !! If you or anyone in your household has an epileptic condition, consult your physician before using the strobe feature. Immediately discontinue use of the App and consult a physician if you experience any of the following symptoms: dizziness, altered vision, eye or muscle twitches, loss of awareness, disorientation, any involuntary movement, or convulsions.

By using this App, you acknowledge and accept this risk and agree that you are using the strobe feature at your own risk.

2. Disclaimer of Warranties

The App is provided to you "AS IS" and "AS AVAILABLE," with all faults and defects without warranty of any kind. To the maximum extent permitted under applicable law, we expressly disclaim all warranties, whether express, implied, statutory, or otherwise, with respect to the App, including all implied warranties of merchantability, fitness for a particular purpose, title, and non-infringement.

We do not warrant that the App will meet your requirements, achieve any intended results, be compatible or work with any other software, applications, systems, or services, operate without interruption, meet any performance or reliability standards, or be error-free.

3. Limitation of Liability

To the fullest extent permitted by applicable law, in no event shall we, our affiliates, or licensors be liable for any personal injury, death, property damage, or any direct, indirect, incidental, special, consequential, or punitive damages whatsoever, including but not limited to, damages for loss of profits, loss of data, business interruption, or any other commercial damages or losses, arising out of or related to your use or inability to use the App, however caused, regardless of the theory of liability (contract, tort, or otherwise) and even if we have been advised of the possibility of such damages.

Your sole and exclusive remedy for any dissatisfaction with the App is to stop using the App.

Privacy Policy
1. Information We Collect

Our App is designed with your privacy in mind. We do not collect any Personally Identifiable Information (PII) such as your name, email address, location, or contacts.

The only data the App handles is related to your in-app preferences, which are stored exclusively on your own device. This includes:

Color Presets: Custom colors you save for the screen flashlight feature.

Theme and Appearance Settings: Your choices for the app's background color, such as using a Material You theme, AMOLED black, or another custom color.

Strobe Interval: The speed setting you choose for the strobe light feature.

This information is saved locally on your device using the SharedPreferences feature and is never transmitted to us or any third party. It is used solely to provide you with a personalized experience each time you open the App.

2. How We Use Information

The preference data stored on your device is used only to:

Save your settings so you don't have to reconfigure the app every time it opens.

Allow the app to function as you have customized it.

3. Permissions

To provide its core functionality, our App requires the following permission:

Flashlight (Camera) Permission: This permission is required to access and control your device's camera flash (LED light). The App uses this permission only to turn the flashlight on and off as you direct. It does not capture any photos or videos, nor does it access your camera for any other purpose.

4. Third-Party Links

The settings page of our App contains links to external websites, such as GitHub and Ko-fi, for informational and support purposes. If you click on these links, you will be directed to that third-party's site.

Please be aware that these external sites are not operated by us. Therefore, we strongly advise you to review the Privacy Policy of these websites. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.

5. Data Security

The security of your information is important to us. Since all preference data is stored locally on your device, its security is handled by the standard security features of your mobile operating system. We do not transmit or store this data on external servers.

6. Children's Privacy

Our App does not address anyone under the age of 13. We do not knowingly collect any information from children. As we do not collect personally identifiable information, we would not knowingly have any data from a child.

7. Changes to This Policy

We may update our Terms of Service & Privacy Policy from time to time. We will notify you of any changes by posting the new policy within the app, via our newsletter, our website and on our app store listing. You are advised to review this policy on the website periodically for any changes. Changes are effective when they are posted.

8. Contact Us

If you have any questions or suggestions about our Terms of Service or Privacy Policy, do not hesitate to contact me.

9. Acknowledgment

By using our App, you acknowledge that you have read and understood these Terms of Service and Privacy Policy and agree to be bound by them.


          ''',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}