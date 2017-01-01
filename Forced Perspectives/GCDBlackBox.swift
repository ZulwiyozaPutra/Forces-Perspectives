//
//  GCDBlackBox.swift
//  Forced Perspectives
//
//  Created by Zulwiyoza Putra on 1/2/17.
//  Copyright © 2017 Zulwiyoza Putra. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
