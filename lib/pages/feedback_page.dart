import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../theme/style.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int rating = 0; // Rating controller in main widget
  TextEditingController feedbackController = TextEditingController(); // Text field controller
  TextEditingController featureRequestsController = TextEditingController(); // Feature requests text field controller
  TextEditingController issuesGeneralController = TextEditingController(); // Issues and general feedback controller
  List<String> selectedFeatures = []; // Selected feature chips

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('⁂ ※ feedback ⁑ ⁂')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _FeedbackInfo(),
                SizedBox(height: 20),
                _FeedbackRating(
                  rating: rating,
                  onRatingChanged: (newRating) {
                    setState(() {
                      rating = newRating;
                    });
                  },
                  feedbackController: feedbackController,
                ),
                SizedBox(height: 20),
                _FeatureRequests(
                  selectedFeatures: selectedFeatures,
                  onFeaturesChanged: (newFeatures) {
                    setState(() {
                      selectedFeatures = newFeatures;
                    });
                  },
                  featureRequestsController: featureRequestsController,
                ),
                SizedBox(height: 20),
                _IssuesAndGeneral(
                  issuesGeneralController: issuesGeneralController,
                ),
                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      // TODO: Submit feedback function
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Submit Feedback',
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Divider(color: theme.colorScheme.onSurfaceVariant,),
                Padding(padding: EdgeInsets.all(20), child: Center(child: Text('Thank you!', style: theme.textTheme.labelLarge!.copyWith(fontStyle: FontStyle.italic))) ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Style.cornerRadius),
        color: theme
            .colorScheme
            .primaryContainer, // todo: try secondaryContainer
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MarkdownBody(
          data: '''
# 👋 Hello from Max!

I'm a **solo developer** trying to make **turing_chat** enjoyable for you and your friends! 

Any **feedback** would help a lot to improve the app. Don't hesitate to only write a _few words_, I'd love to hear from you about:

## 🎨 Design & User Experience

## 🚀 Feature Requests

## 🐛 Issues & Problems

## 💭 General Feedback    

--  

**Every piece of feedback helps :)**

Thank you for being part of the turing_chat community! 🙏

*— Max*
''',
          styleSheet: Style.markdownStyleSheet(context),
        ),
      ),
    );
  }
}

class _FeedbackRating extends StatelessWidget {
  final int rating;
  final Function(int) onRatingChanged;
  final TextEditingController feedbackController;

  const _FeedbackRating({
    required this.rating,
    required this.onRatingChanged,
    required this.feedbackController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Style.cornerRadius),
        color: theme
            .colorScheme
            .secondaryContainer, // todo: try secondaryContainer
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: '''
## 🎨 Design & User Experience
- How do you like the current app and design?
- What was annoying or confusing?
''',
              styleSheet: Style.markdownStyleSheet(context),
            ),
            SizedBox(height: 20),
            Text(
              'Rate your experience:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    onRatingChanged(index + 1);
                  },
                  child: Icon(
                    rating > index ? Icons.star : Icons.star_border,
                    size: 40,
                    color: rating > index 
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onPrimaryContainer.withOpacity(0.5),
                  ),
                );
              }),
            ),
            if (rating > 0) ...[
              SizedBox(height: 8),
              Text(
                'Rating: $rating/5',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(Style.cornerRadius - 8.0)),
                ),
                labelText: 'Your feedback',
                hintText: 'Share your thoughts...',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              style: theme.textTheme.bodyMedium,
              minLines: 4,
              maxLines: 8,
              controller: feedbackController,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRequests extends StatelessWidget {
  final List<String> selectedFeatures;
  final Function(List<String>) onFeaturesChanged;
  final TextEditingController featureRequestsController;

  const _FeatureRequests({
    required this.selectedFeatures,
    required this.onFeaturesChanged,
    required this.featureRequestsController,
  });

  final List<String> availableFeatures = const [
    'Public casual mode',
    'Public ranked mode', 
    'Image sending',
    'Achievements',
    'Challenges',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Style.cornerRadius),
        color: theme
            .colorScheme
            .secondaryContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: '''
## 🚀 Feature Requests
- What new features would you like to see? (e.g. public/ranked game modes, more chat features, etc.)
- How can we make the game more engaging?
''',
              styleSheet: Style.markdownStyleSheet(context),
            ),
            SizedBox(height: 16),
            Text(
              'Features you would be interested in:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: availableFeatures.map((feature) {
                final isSelected = selectedFeatures.contains(feature);
                return FilterChip(
                  label: Text(feature),
                  selected: isSelected,
                  onSelected: (selected) {
                    List<String> newFeatures = List.from(selectedFeatures);
                    if (selected) {
                      newFeatures.add(feature);
                    } else {
                      newFeatures.remove(feature);
                    }
                    onFeaturesChanged(newFeatures);
                  },
                  labelStyle: TextStyle(
                    color: isSelected 
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSecondaryContainer,
                  ),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  selectedColor: theme.colorScheme.primary,
                  checkmarkColor: theme.colorScheme.onPrimary,
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            TextField(
              key: ValueKey('feedbackPage_featureRequest_textField'),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(Style.cornerRadius - 8.0)),
                ),
                labelText: 'Feature requests',
                hintText: 'Describe features you would like to see...',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              style: theme.textTheme.bodyMedium,
              minLines: 4,
              maxLines: 8,
              controller: featureRequestsController,
            ),
          ],
        ),
      ),
    );
  }
}

class _IssuesAndGeneral extends StatelessWidget {
  final TextEditingController issuesGeneralController;

  const _IssuesAndGeneral({
    required this.issuesGeneralController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Style.cornerRadius),
        color: theme
            .colorScheme
            .secondaryContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: '''
## 🐛💭 Issues, Problems & General Feedback
- Did you encounter any bugs or crashes?
- Is something not working as expected?
- Any other thoughts or suggestions?
''',
              styleSheet: Style.markdownStyleSheet(context),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(Style.cornerRadius - 8.0)),
                ),
                labelText: 'Issues & feedback',
                hintText: 'Describe any issues or share your thoughts...',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              style: theme.textTheme.bodyMedium,
              minLines: 4,
              maxLines: 8,
              controller: issuesGeneralController,
            ),
          ],
        ),
      ),
    );
  }
}
