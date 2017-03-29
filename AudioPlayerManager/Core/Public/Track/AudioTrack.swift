//
//  AudioTrack.swift
//  AudioPlayerManager
//
//  Created by Hans Seiffert on 02.08.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

public class AudioTrack : NSObject {

	// MARK: - PUBLIC -

	// MARK: - Properties

	public var playerItem						: AVPlayerItem?

	public var nowPlayingInfo					: [String : NSObject]?

	// MARK: - Lifecycle

	public func loadResource() {
		// Reloads the resource in the child class if necessary.
	}

	public func getPlayerItem() -> AVPlayerItem? {
		// Return the AVPlayerItem in the subclasses
		return nil
	}

	// MARK: - Now playing info

	public func initNowPlayingInfo() {
		// Init the now playing info here
		self.nowPlayingInfo = [String : NSObject]()
		self.updateNowPlayingInfoPlaybackDuration()
	}

	// MARK: - Helper

	public func durationInSeconds() -> Float {
		if let _playerItem = self.playerItem where _playerItem.duration != kCMTimeIndefinite {
			return Float(CMTimeGetSeconds(_playerItem.duration))
		}
		return Float(0)
	}

	public func currentProgress() -> Float {
		if (self.durationInSeconds() > 0) {
			return self.currentTimeInSeconds() / self.durationInSeconds()
		}
		return Float(0)
	}

	public func currentTimeInSeconds() -> Float {
		if let _playerItem = self.playerItem {
			let currentTime = Float(CMTimeGetSeconds(_playerItem.currentTime()))
			let duration = self.durationInSeconds()
			guard (duration <= 0.0 || currentTime <= duration) else {
				return duration
			}

			return currentTime
		}
		return Float(0)
	}

	// MARK: - Displayable Time strings

	public func displayablePlaybackTimeString() -> String {
		return AudioTrack.displayableStringFromTimeInterval(NSTimeInterval(self.currentTimeInSeconds()))
	}

	public func displayableDurationString() -> String {
		return AudioTrack.displayableStringFromTimeInterval(NSTimeInterval(self.durationInSeconds()))
	}

	public func displayableTimeLeftString() -> String {
		let timeLeft = self.durationInSeconds() - self.currentTimeInSeconds()
		return "-\(AudioTrack.displayableStringFromTimeInterval(NSTimeInterval(timeLeft)))"
	}

	public func isPlayable() -> Bool {
		return true
	}

	// MARK: - INTERNAL -

	// MARK: - Lifecycle

	func prepareForPlaying(playerItem: AVPlayerItem) {
		self.playerItem = playerItem
		self.initNowPlayingInfo()
	}

	func cleanupAfterPlaying() {
		self.playerItem = nil
		self.nowPlayingInfo?.removeAll()
	}

	// MARK: - Now playing info

	public func updateNowPlayingInfoPlaybackDuration() {
		if let _playerItem = self.playerItem {
			let timeInSeconds = CMTimeGetSeconds(_playerItem.asset.duration)
			// Check ig the time isn't NaN. This can happen eg. for podcasts
			let duration : NSNumber? = ((timeInSeconds.isNaN == false) ? NSNumber(float: Float(timeInSeconds)) : nil)
			self.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = duration
		}
	}

	public func updateNowPlayingInfoPlaybackTime() {
		let currentTime = self.currentTimeInSeconds()
		// Check ig the time isn't NaN.
		let currentTimeAsNumber : NSNumber? = ((currentTime.isNaN == false) ? NSNumber(float: Float(currentTime)) : nil)
		self.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTimeAsNumber
	}

	// MARK: - Helper

	public func identifier() -> String? {
		// Return an unqiue identifier of the item in the subclasses
		return nil
	}

	// MARK: NSTimeInterval

	class func displayableStringFromTimeInterval(timeInterval: NSTimeInterval) -> String {
		let dateComponentsFormatter = NSDateComponentsFormatter()
		dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehavior.Pad
		if (timeInterval >= 60 * 60) {
			dateComponentsFormatter.allowedUnits = [.Hour, .Minute, .Second]
		} else {
			dateComponentsFormatter.allowedUnits = [.Minute, .Second]
		}
		return dateComponentsFormatter.stringFromTimeInterval(timeInterval) ?? "0:00"
	}
}
