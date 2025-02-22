//
//  RecentSearchView.swift
//  LMessenger
//
//

import SwiftUI

struct RecentSearchView: View {
    @Environment(\.managedObjectContext) var objectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date)]) var results: FetchedResults<SearchResult> // date를 기준으로 정렬.
    // FetchedResults에 해당 결과값을 할당해줍니다. SearchData 모델을 만들 때 SearchResult를 정의함으로써 컴파일러는 SearchResult라는 NSManagedObject를 생성해줍니다.
    // NSManagedObject 객체는 코어 데이터가 관리하고 managedObjectContext내에 유지가 됩니다.
    
    var onTapResult: ((String?) -> Void)
    
    var body: some View {
        VStack(spacing: 8) {
            titleView
                .padding(.bottom, 20)
            
            if results.isEmpty {
                Text("검색 내역이 없습니다.")
                    .font(.system(size: 10))
                    .foregroundColor(.greyDeep)
                    .padding(.vertical, 54)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(results, id: \.self) { result in
                            HStack {
                                Button {
                                    onTapResult(result.name)
                                } label: {
                                    Text(result.name ?? "")
                                        .font(.system(size: 14))
                                        .foregroundColor(.bkText)
                                }
                                Spacer()
                                Button {
                                    objectContext.delete(result) // 실제 영구 저장소가 아닌 Context 내에서 지우는 것
                                    try? objectContext.save() // 실제 영구 저장소에 적용
                                } label: {
                                    Image("close_search", label: Text("검색어 삭제"))
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                }
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 30)
    }
    
    var titleView: some View {
        HStack {
            Text("최근 검색어")
                .font(.system(size: 10, weight: .bold))
            Spacer()
        }
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    RecentSearchView { _ in
        
    }
}
