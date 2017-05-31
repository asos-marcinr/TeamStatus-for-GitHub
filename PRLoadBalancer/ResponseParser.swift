//
//  ResponseParser.swift
//  PRLoadBalancer
//
//  Created by Marcin Religa on 31/05/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

final class ResponseParser {
	func parseResponse(data: Data) -> [PullRequest]? {
		do {
			let json = try JSONSerialization.jsonObject(with: data, options: [])

			if let responseData = json as? [String: Any] {
				return parse(json: responseData)
			}
		} catch {
			print("JSON parsing error")
		}

		return nil
	}

	private func parse(json: [String: Any]) -> [PullRequest] {
		var allPullRequests: [PullRequest] = []

		if let data = json["data"] as? [String: Any] {
			if let repository = data["repository"] as? [String: Any] {
				if let pullRequests = repository["pullRequests"] as? [String: Any] {
					if let edges = pullRequests["edges"] as? [[String: Any]] {
						for edge in edges {
							if let node = edge["node"] as? [String: Any] {
								if let id = node["id"] as? String, let title = node["title"] as? String {
									var pullRequestData = PullRequest(id: id, title: title)

									if let reviewRequests = node["reviewRequests"] as? [String: Any] {
										if let edges = reviewRequests["edges"] as? [[String: Any]] {
											for edge in edges {
												if let node = edge["node"] as? [String: Any] {
													if let reviewer = node["reviewer"] as? [String: Any] {
														if let login = reviewer["login"] as? String {
															pullRequestData.reviewersRequested.append(Reviewer(login: login))
														}
													}
												}
											}
										}
									}

									if let reviews = node["reviews"] as? [String: Any] {
										if let edges = reviews["edges"] as? [[String: Any]] {
											for edge in edges {
												if let node = edge["node"] as? [String: Any] {

													if let reviewer = node["author"] as? [String: Any] {
														if let login = reviewer["login"] as? String {
															pullRequestData.reviewersReviewed.append(Reviewer(login: login))
														}
													}
												}
											}
										}
									}
									
									allPullRequests.append(pullRequestData)
								}
							}
						}
					}
				}
			}
		}

		return allPullRequests
	}
}
