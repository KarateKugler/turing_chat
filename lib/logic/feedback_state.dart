part of 'feedback_cubit.dart';

final class FeedbackState extends Equatable {
  const FeedbackState({
    this.rating = 0,
    this.designFeedback = '',
    this.selectedFeatures = const [],
    this.featureRequests = '',
    this.issuesGeneral = '',
  });

  final int rating;
  final String designFeedback;
  final List<String> selectedFeatures;
  final String featureRequests;
  final String issuesGeneral;

  /// Immutable update methods
  FeedbackState withRating(int rating) {
    return FeedbackState(
      rating: rating,
      designFeedback: designFeedback,
      selectedFeatures: selectedFeatures,
      featureRequests: featureRequests,
      issuesGeneral: issuesGeneral,
    );
  }

  FeedbackState withDesignFeedback(String feedback) {
    return FeedbackState(
      rating: rating,
      designFeedback: feedback,
      selectedFeatures: selectedFeatures,
      featureRequests: featureRequests,
      issuesGeneral: issuesGeneral,
    );
  }

  FeedbackState withSelectedFeatures(List<String> features) {
    return FeedbackState(
      rating: rating,
      designFeedback: designFeedback,
      selectedFeatures: List.from(features),
      featureRequests: featureRequests,
      issuesGeneral: issuesGeneral,
    );
  }

  FeedbackState withFeatureRequests(String requests) {
    return FeedbackState(
      rating: rating,
      designFeedback: designFeedback,
      selectedFeatures: selectedFeatures,
      featureRequests: requests,
      issuesGeneral: issuesGeneral,
    );
  }

  FeedbackState withIssuesGeneral(String feedback) {
    return FeedbackState(
      rating: rating,
      designFeedback: designFeedback,
      selectedFeatures: selectedFeatures,
      featureRequests: featureRequests,
      issuesGeneral: feedback,
    );
  }

  @override
  List<Object?> get props => [rating, designFeedback, selectedFeatures, featureRequests, issuesGeneral];

  @override
  String toString() {
    return 'FeedbackState(rating: $rating, designFeedback: "$designFeedback", selectedFeatures: $selectedFeatures, featureRequests: "$featureRequests", issuesGeneral: "$issuesGeneral")';
  }
} 