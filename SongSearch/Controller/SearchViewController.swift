//
//  SearchViewController.swift
//  SongSearch
//
//  Created by joonwon lee on 02/04/2019.
//  Copyright © 2019 joonwon.lee. All rights reserved.
//

import UIKit
import AVKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var tracks: [Track] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count // 데이터가 몇 개인지 뷰 컨트롤러에게 물어본다
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ResultCell else {
            return UITableViewCell()
        }
        
        cell.configure(track: tracks[indexPath.row])
        return cell
    }
}

// 테이블뷰의 셀이 클릭됐을 때 어떻게 반응할 것인가
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissKeyboard()
        // TODO: Play Song
        // previewUrl은 Track.swift에 있는 previewUrl
        guard let previewUrl = URL(string: tracks[indexPath.row].previewUrl) else { return }
        
        let playerViewController = AVPlayerViewController() // AVPlayerViewController를 사용하려면 AVKit을 import 해야 한다
        present(playerViewController, animated: true, completion: nil)
        let player = AVPlayer(url: previewUrl)
        playerViewController.player = player
        player.play() // 바로 플레이까지 진행한다
    }
}

// 서치바에다가 검색을 넣고 클릭하여 네트워킹하는 부분
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard() // 서치버튼을 클릭했을 때 키보드가 사라지게 한다
        // TODO: Search Code: 검색어를 입력하고 받는 부분
        guard let searchText = searchBar.text, searchText.isEmpty == false else { return }
        
        var urlComponents = URLComponents(string: "https://itunes.apple.com/search?media=music&entity=musicVideo")!
        let queryItem = URLQueryItem(name: "term", value: "지드래곤")
        urlComponents.queryItems?.append(queryItem)
        guard let requestURL = urlComponents.url else { return }
        // 있으면 이 밑의 내용을 하자
        URLSession.shared.dataTask(with: requestURL) { [weak self] (data, response, error) in
            // parse 앞에 붙일 strongSelf
            guard let strongSelf = self else { return }
            
            // Client-side Error
            guard error == nil else { return }
            
            // Server-side Error
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return }
            let successRange = 200..<300
            
            guard successRange.contains(statusCode) else {
                // serverside error handle
                return
            }
            
            guard let resultData = data else { return }
            // Data > Object =====> Parsing
            print("---> data: \(resultData)")
            
            // 현재 이 parse는 클로저 안에 있는 상태이기 때문에 weak self를 만들어 retain cycle이 생기지 않도록 해줘야 한다
            // 위에서 guard로 만든 strongSelf를 해주면 retain cycle을 막을 수 있다
            strongSelf.tracks = strongSelf.parse(data: resultData) ?? []
            DispatchQueue.main.async { // UI와 관련된 부분이므로 메인스레드에서 작업이 이루어져야 한다.
                strongSelf.tableView.reloadData() // 검색한 결과들이 나오게 해준다
                strongSelf.tableView.setContentOffset(CGPoint.zero, animated: false)
            }
            // parsing
            // track에다가 parsing된 data를 세팅
            // tableView를 reload하여 데이터를 업데이트 -> tableView.reloadData()
            // tableView.setContentOffset(0)
        }.resume() // requestURL을 파라미터로 받고, 이를 바로 resume()을 해줌으로써 서버와 네트워킹을 할 수 있게 된다
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached // 상단바를 어디까지 쓸 것인지를 보여준다
    }
}

// 코더블로 아주 쉽게 데이터를 파싱할 수 있다
extension SearchViewController {
    func parse(data: Data) -> [Track]? { //서버에서 받은 데이터(data: Data)를 Track의 배열 형태로 표현하고 싶은 상태 -> 디코딩을 해줘야 함
        // 받은 데이터를 파싱하는 곳
        // TODO: Parse Track From Data
        do {
            let decoder = JSONDecoder() // 디코더로 디코딩을 한다
            let response = try decoder.decode(Response.self, from: data) // 여기서 Response는 Track.swift에 있음
            let trackList = response.results
            return trackList
        } catch let error {
            print("---> error: \(error.localizedDescription)")
            return nil
        }
    }
}


