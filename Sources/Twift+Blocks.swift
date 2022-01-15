import Foundation

extension Twift {
  // MARK: Blocks methods
  
  /// Returns a list of users who are blocked by the specified user ID.
  ///
  /// Equivalent to `GET /2/users/:id/blocking`.
  /// - Parameters:
  ///   - userId: The user ID whose blocked users you would like to retrieve
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned user objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned ``TwitterAPIDataIncludesAndMeta`` struct.
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A Twitter API response object containing an array of ``User`` structs and any pinned tweets in the `includes` property
  public func getBlockedUsers(for userId: User.ID,
                              userFields: [User.Fields] = [],
                              expansions: [User.Expansions] = [],
                              tweetFields: [Tweet.Fields] = [],
                              paginationToken: String? = nil,
                              maxResults: Int = 100
  ) async throws -> TwitterAPIDataIncludesAndMeta<[User], User.Includes, Meta> {
    switch maxResults {
    case 0...1000:
      break
    default:
      throw TwiftError.RangeOutOfBoundsError(min: 1, max: 1000, fieldName: "maxResults", actual: maxResults)
    }
    
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    return try await call(userFields: userFields,
                          tweetFields: tweetFields,
                          expansions: expansions.map { $0.rawValue },
                          route: .blocking(userId),
                          queryItems: queryItems,
                          expectedReturnType: TwitterAPIDataIncludesAndMeta.self)
  }
  
  /// Causes the source user to block the target user. The source user ID must match the currently authenticated user ID.
  ///
  /// Equivalent to `POST /2/users/:id/blocking`
  /// - Parameters:
  ///   - sourceUserId: The user ID who you would like to initiate the block on behalf of. It must match the user ID of the currently authenticated user.
  ///   - targetUserId: The user ID of the user you would like the source user to block.
  /// - Returns: A ``BlockResponse`` indicating the blocked status.
  public func blockUser(sourceUserId: User.ID, targetUserId: User.ID) async throws -> TwitterAPIData<BlockResponse> {
    let body = ["target_user_id": targetUserId]
    let serializedBody = try JSONSerialization.data(withJSONObject: body)
    return try await call(route: .blocking(sourceUserId),
                          method: .POST,
                          body: serializedBody,
                          expectedReturnType: TwitterAPIData.self)
  }
  
  /// Causes the source user to block the target user. The source user ID must match the currently authenticated user ID.
  ///
  /// Equivalent to `DELETE /2/users/:source_user_id/blocking/:target_user_id`
  /// - Parameters:
  ///   - sourceUserId: The user ID who you would like to initiate the block on behalf of. It must match the user ID of the currently authenticated user.
  ///   - targetUserId: The user ID of the user you would like the source user to block.
  /// - Returns: A ``BlockResponse`` indicating the blocked status.
  public func unblockUser(sourceUserId: User.ID, targetUserId: User.ID) async throws -> TwitterAPIData<BlockResponse> {
    return try await call(route: .deleteBlock(sourceUserId: sourceUserId, targetUserId: targetUserId),
                          method: .DELETE,
                          expectedReturnType: TwitterAPIData.self)
  }
}


/// A response object containing information relating to a block status.
public struct BlockResponse: Codable {
  /// Indicates whether the id is blocking the specified user as a result of this request.
  public let blocking: Bool
}
