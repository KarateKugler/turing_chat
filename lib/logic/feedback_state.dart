part of 'feedback_cubit.dart';

enum FeedbackStatus { initial, inProgress, success, error }

final class FeedbackState extends Equatable {
  const FeedbackState._({
    required this.status,
    required this.rating,
    required this.designFeedback,
    required this.selectedFeatures,
    required this.featureRequests,
    required this.issuesGeneral,
  });

  const FeedbackState({
    FeedbackStatus? status,
    int? rating,
    String? designFeedback,
    List<String>? selectedFeatures,
    String? featureRequests,
    String? issuesGeneral,
  }) : this._(
    status: status ?? FeedbackStatus.initial,
    rating: rating ?? 0,
    designFeedback: designFeedback ?? '',
    selectedFeatures: selectedFeatures ?? const [],
    featureRequests: featureRequests ?? '',
    issuesGeneral: issuesGeneral ?? '',
  );

  final FeedbackStatus status;
  final int rating;
  final String designFeedback;
  final List<String> selectedFeatures;
  final String featureRequests;
  final String issuesGeneral;

  /// Immutable update methods
  FeedbackState withStatus(FeedbackStatus status) {
    return FeedbackState._(
      status: status,
      rating: rating,
      designFeedback: designFeedback,
      selectedFeatures: selectedFeatures,
      featureRequests: featureRequests,
      issuesGeneral: issuesGeneral,
    );
  }

  FeedbackState withRating(int rating) {
    return FeedbackState._(
      status: status,
      rating: rating,
      designFeedback: designFeedback,
      selectedFeatures: selectedFeatures,
      featureRequests: featureRequests,
      issuesGeneral: issuesGeneral,
    );
  }

  FeedbackState withDesignFeedback(String feedback) {
    return FeedbackState._(
      status: status,
      rating: rating,
      designFeedback: feedback,
      selectedFeatures: selectedFeatures,
      featureRequests: featureRequests,
      issuesGeneral: issuesGeneral,
    );
  }

  FeedbackState withSelectedFeatures(List<String> features) {
    return FeedbackState._(
      status: status,
      rating: rating,
      designFeedback: designFeedback,
      selectedFeatures: List.from(features),
      featureRequests: featureRequests,
      issuesGeneral: issuesGeneral,
    );
  }

  FeedbackState withFeatureRequests(String requests) {
    return FeedbackState._(
      status: status,
      rating: rating,
      designFeedback: designFeedback,
      selectedFeatures: selectedFeatures,
      featureRequests: requests,
      issuesGeneral: issuesGeneral,
    );
  }

  FeedbackState withIssuesGeneral(String feedback) {
    return FeedbackState._(
      status: status,
      rating: rating,
      designFeedback: designFeedback,
      selectedFeatures: selectedFeatures,
      featureRequests: featureRequests,
      issuesGeneral: feedback,
    );
  }

  @override
  List<Object?> get props => [status, rating, designFeedback, selectedFeatures, featureRequests, issuesGeneral];

  @override
  String toString() {
    return 'FeedbackState(status: $status, rating: $rating, designFeedback: "$designFeedback", selectedFeatures: $selectedFeatures, featureRequests: "$featureRequests", issuesGeneral: "$issuesGeneral")';
  }
} 