import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_api/supabase_api.dart';

part 'feedback_state.dart';

/// Simple cubit to manage feedback form state
class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit(this._databaseService) : super(const FeedbackState());

  final DatabaseService _databaseService;

  /// Change notifiers for each field
  void ratingChanged(int rating) => emit(state.withRating(rating));

  void designFeedbackChanged(String feedback) =>
      emit(state.withDesignFeedback(feedback));

  void selectedFeaturesChanged(List<String> features) =>
      emit(state.withSelectedFeatures(features));

  void featureRequestsChanged(String requests) =>
      emit(state.withFeatureRequests(requests));

  void issuesGeneralChanged(String feedback) =>
      emit(state.withIssuesGeneral(feedback));

  /// Submit feedback function
  Future<void> submitFeedback() async {
    emit(state.withStatus(FeedbackStatus.inProgress));

    try {
      await _databaseService.submitFeedback(
        rating: state.rating,
        design: state.designFeedback,
        featuresList: state.selectedFeatures,
        features: state.featureRequests,
        issuesOther: state.issuesGeneral,
      );

      emit(FeedbackState(status: FeedbackStatus.success));
      print('Feedback submitted successfully');
    } catch (e) {
      emit(state.withStatus(FeedbackStatus.error));
      print('Error submitting feedback: $e');
      rethrow;
    }
  }
}
