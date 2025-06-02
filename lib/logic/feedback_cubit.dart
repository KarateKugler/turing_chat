import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'feedback_state.dart';

/// Simple cubit to manage feedback form state
class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit() : super(const FeedbackState());

  /// Change notifiers for each field
  void ratingChanged(int rating) => emit(state.withRating(rating));

  void designFeedbackChanged(String feedback) => emit(state.withDesignFeedback(feedback));

  void selectedFeaturesChanged(List<String> features) => emit(state.withSelectedFeatures(features));

  void featureRequestsChanged(String requests) => emit(state.withFeatureRequests(requests));

  void issuesGeneralChanged(String feedback) => emit(state.withIssuesGeneral(feedback));

  /// Submit feedback function (not implemented yet)
  Future<void> submitFeedback() async {
    // TODO: Implement feedback submission
    print('Submitting feedback: ${state.toString()}');
  }
} 