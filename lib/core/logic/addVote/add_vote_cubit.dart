import 'package:bloc/bloc.dart';
import 'package:e_learning/core/api_services/api_services.dart';
import 'package:meta/meta.dart';

part 'add_vote_state.dart';

class AddVoteCubit extends Cubit<AddVoteState> {
  AddVoteCubit() : super(AddVoteInitial());

  final ApiServices _api=ApiServices();

  Future<void>addVote({required String post_id,required String option_id,required String user_id,})async{
    await _api.postData(path: 'poll_votes', data: {
      "post_id":post_id,
      "option_id":option_id,
      "user_id":user_id
    });
  }
}
