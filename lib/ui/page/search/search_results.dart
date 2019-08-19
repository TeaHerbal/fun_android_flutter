import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:fun_android/model/article.dart';
import 'package:fun_android/provider/provider_widget.dart';
import 'package:fun_android/ui/widget/article_list_Item.dart';
import 'package:fun_android/ui/widget/like_animation.dart';
import 'package:fun_android/ui/widget/page_state_switch.dart';
import 'package:fun_android/view_model/colletion_model.dart';
import 'package:fun_android/view_model/search_model.dart';

class SearchResults extends StatelessWidget {
  final String keyword;
  final SearchHistoryModel searchHistoryModel;

  SearchResults({this.keyword, this.searchHistoryModel});

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<CollectionAnimationModel>(
        model: CollectionAnimationModel(),
        builder: (context, collectionAnimationModel, child) => Stack(
              children: <Widget>[child, LikeAnimatedWidget()],
            ),
        child: ProviderWidget<SearchResultModel>(
          model: SearchResultModel(
              keyword: keyword, searchHistoryModel: searchHistoryModel),
          onModelReady: (model) {
            model.initData();
          },
          builder: (context, model, child) {
            if (model.busy) {
              return PageStateLoading();
            }
            if (model.error) {
              return PageStateError(onPressed: model.initData);
            }
            if (model.empty) {
              return PageStateEmpty(onPressed: model.initData);
            }
            return SmartRefresher(
                controller: model.refreshController,
                header: WaterDropHeader(),
                onRefresh: model.refresh,
                onLoading: model.loadMore,
                enablePullUp: true,
                child: ListView.builder(
                    itemCount: model.list.length,
                    itemBuilder: (context, index) {
                      Article item = model.list[index];
                      return ArticleItemWidget(item);
                    }));
          },
        ));
  }
}
