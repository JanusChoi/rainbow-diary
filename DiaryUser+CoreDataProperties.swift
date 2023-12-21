//
//  DiaryUser+CoreDataProperties.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/21.
//
//

import Foundation
import CoreData


extension DiaryUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DiaryUser> {
        return NSFetchRequest<DiaryUser>(entityName: "DiaryUser")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var username: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var entries: NSSet?
    @NSManaged public var summaries: NSSet?
    @NSManaged public var personality: Personality?

}

// MARK: Generated accessors for entries
extension DiaryUser {

    @objc(addEntriesObject:)
    @NSManaged public func addToEntries(_ value: Entry)

    @objc(removeEntriesObject:)
    @NSManaged public func removeFromEntries(_ value: Entry)

    @objc(addEntries:)
    @NSManaged public func addToEntries(_ values: NSSet)

    @objc(removeEntries:)
    @NSManaged public func removeFromEntries(_ values: NSSet)

}

// MARK: Generated accessors for summaries
extension DiaryUser {

    @objc(addSummariesObject:)
    @NSManaged public func addToSummaries(_ value: DaySummary)

    @objc(removeSummariesObject:)
    @NSManaged public func removeFromSummaries(_ value: DaySummary)

    @objc(addSummaries:)
    @NSManaged public func addToSummaries(_ values: NSSet)

    @objc(removeSummaries:)
    @NSManaged public func removeFromSummaries(_ values: NSSet)

}

extension DiaryUser : Identifiable {

}
