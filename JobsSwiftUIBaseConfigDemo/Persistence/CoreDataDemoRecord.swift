//
//  CoreDataDemoRecord.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年11月15日，星期日.
//

import Foundation

/// 页面只消费值快照，托管对象和上下文始终留在持久化适配层。
struct CoreDataDemoRecord: Identifiable,
                           Equatable {

    let id: UUID
    let title: String
    let createdAt: Date
    let isComplete: Bool
}
