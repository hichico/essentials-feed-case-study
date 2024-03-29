//
//  FeedUIIntegrationTestHelpers.swift
//  EssentialsAppTests
//
//  Created by Chico Pereira on 27/03/2022.
//

import EssentialsFeed
import EssentialsFeedPresentation
import EssentialsFeediOS
import UIKit
import Combine
import XCTest

extension FeedUIIntegrationTests {
    
    class LoaderSpy {
            
            // MARK: - FeedLoader
            
            private var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
            
            var loadFeedCallCount: Int {
                return feedRequests.count
            }
            
            func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
                let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
                feedRequests.append(publisher)
                return publisher.eraseToAnyPublisher()
            }
            
            func completeFeedLoadingWithError(at index: Int = 0) {
                feedRequests[index].send(completion: .failure(anyNSError()))
            }
            
            func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
                feedRequests[index].send(Paginated(items: feed, loadMorePublisher: { [weak self] in
                    self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
                }))
                feedRequests[index].send(completion: .finished)
            }
            
            // MARK: - LoadMoreFeedLoader
            
            private var loadMoreRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
            
            var loadMoreCallCount: Int {
                return loadMoreRequests.count
            }
            
            func loadMorePublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
                let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
                loadMoreRequests.append(publisher)
                return publisher.eraseToAnyPublisher()
            }
            
            func completeLoadMore(with feed: [FeedImage] = [], lastPage: Bool = false, at index: Int = 0) {
                loadMoreRequests[index].send(Paginated(
                                                items: feed,
                                                loadMorePublisher: lastPage ? nil : { [weak self] in
                                                    self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
                                                }))
            }
            
            func completeLoadMoreWithError(at index: Int = 0) {
                loadMoreRequests[index].send(completion: .failure(anyNSError()))
            }
            
            // MARK: - FeedImageDataLoader
            
            private var imageRequests = [(url: URL, publisher: PassthroughSubject<Data, Error>)]()
            
            var loadedImageURLs: [URL] {
                return imageRequests.map { $0.url }
            }
            
            private(set) var cancelledImageURLs = [URL]()
            
            func loadImageDataPublisher(from url: URL) -> AnyPublisher<Data, Error> {
                let publisher = PassthroughSubject<Data, Error>()
                imageRequests.append((url, publisher))
                return publisher.handleEvents(receiveCancel: { [weak self] in
                    self?.cancelledImageURLs.append(url)
                }).eraseToAnyPublisher()
            }
            
            func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
                imageRequests[index].publisher.send(imageData)
                imageRequests[index].publisher.send(completion: .finished)
            }
            
            func completeImageLoadingWithError(at index: Int = 0) {
                imageRequests[index].publisher.send(completion: .failure(anyNSError()))
            }
        }
        
    
}

extension ListViewController {
    
    public override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
        
        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }

    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }

    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: row)

        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)

        return view
    }
    
    func simulateTapOnFeedImage(at row: Int) {
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }

    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }

    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)

        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    func simulateLoadMoreFeedAction() {
        guard let view = loadMoreFeedCell() else { return }
        
        let delegate = tableView.delegate
        let index = IndexPath(row: 0, section: feedLoadMoreSection)
        delegate?.tableView?(tableView, willDisplay: view, forRowAt: index)
    }
    
    func simulateTapOnLoadMoreFeedError() {
        let delegate = tableView.delegate
        let index = IndexPath(row: 0, section: feedLoadMoreSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }
    
    var isShowingLoadMoreFeedIndicator: Bool {
        return loadMoreFeedCell()?.isLoading == true
    }
    
    private func loadMoreFeedCell() -> LoadMoreCell? {
        cell(row: 0, section: feedLoadMoreSection) as? LoadMoreCell
    }
    
    var canLoadMoreFeed: Bool {
        loadMoreFeedCell() != nil
    }

    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
    func simulateErrorViewTap() {
        errorView.simulateTap()
    }

    var errorMessage: String? {
        return errorView.message
    }
    
    var loadMoreFeedErrorMessage: String? {
        return loadMoreFeedCell()?.message 
    }

    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfRows(in section: Int) -> Int {
         tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
     }
    
    func cell(row: Int, section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

extension ListViewController {
    func numberOfRenderedComments() -> Int {
        numberOfRows(in: commentsSection)
    }
    
    func commentMessage(at row: Int) -> String? {
        commentView(at: row)?.messageLabel.text
    }
    
    func commentDate(at row: Int) -> String? {
        commentView(at: row)?.dateLabel.text
    }
    
    func commentUsername(at row: Int) -> String? {
        commentView(at: row)?.usernameLabel.text
    }
    
    private func commentView(at row: Int) -> ImageCommentCell? {
        guard numberOfRenderedComments() > row else {
            return nil
        }
        
        let dataSource = tableView.dataSource
        let index = IndexPath(row: row, section: commentsSection)
        return dataSource?.tableView(tableView, cellForRowAt: index) as? ImageCommentCell
    }
    
    var commentsSection: Int {
        return 0
    }
}

extension ListViewController {

    func numberOfRenderedFeedImageViews() -> Int {
        numberOfRows(in: feedImagesSection)
    }

    func feedImageView(at row: Int) -> UITableViewCell? {
        cell(row: row, section: feedImagesSection)
    }

    var feedImagesSection: Int {
        return 0
    }
    
    var feedLoadMoreSection: Int {
        return 1
    }
}

extension FeedImageCell {
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }

    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }

    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }

    var isShowingRetryAction: Bool {
        return !feedImageRetryButton.isHidden
    }

    var locationText: String? {
        return locationLabel.text
    }

    var descriptionText: String? {
        return descriptionLabel.text
    }

    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }
}

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

private class DummyView: ResourceView {
    func display(_ viewModel: Any) {}
}

var loadError: String {
    LoadResourcePresenter<Any, DummyView>.loadError
}

var feedTitle: String {
    FeedPresenter.title
}

var commentsTitle: String {
    ImageCommentsPresenter.title
}
