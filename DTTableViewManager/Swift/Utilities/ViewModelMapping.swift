//
//  CellModelMapping.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 15.07.15.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import DTModelStorage

enum ViewType : String
{
    case Cell = "Cell"
    case Header = "Header"
    case Footer = "Footer"
}

struct ViewModelMapping
{
    let viewType : ViewType
    let viewTypeMirror: _MirrorType
    let modelTypeMirror: _MirrorType
    let updateBlock : (Any, Any) -> ()
}

extension ViewModelMapping : CustomStringConvertible
{
    var description : String
    {
        return "Mapping type : \(viewType.rawValue) \n" +
            "View Type : \(viewTypeMirror.value) \n" +
            "Model Type : \(modelTypeMirror.value) \n"
    }
}