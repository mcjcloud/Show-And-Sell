//
//  MessagesTableViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 1/4/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import UIKit

class MessagesTableViewController: UITableViewController {
    
    var messages = [Message]()
    
    // variables assigned by prepare for segue
    var item: Item!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Add button for posting a message to the thread.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(postMessage))
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(handleRefresh))
        self.navigationItem.title = "Chat"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        handleRefresh()
    }
    override func viewWillAppear(_ animated: Bool) {
        handleRefresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // one section for all messages.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return count of messages array
        return messages.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageTableViewCell

        // get the messages sorted by the date, at the given index.
        let message = messages.sorted(by: {
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d/yyyy hh:mm:ss a"
            
            let date1 = formatter.date(from: $0.datePosted)
            let date2 = formatter.date(from: $1.datePosted)
            
            return date1! < date2!
        })[indexPath.row]
        // Configure the cell...
        cell.nameLabel.text = message.posterName
        cell.messageLabel.text = message.body
        cell.selectionStyle = .none
        
        // customize based on who sent.
        if message.posterId == (AppDelegate.user?.userId ?? "") {
            cell.backgroundColor = UIColor(colorLiteralRed: 0.298, green: 0.686, blue: 0.323, alpha: 0.5286)    // Green
            cell.nameLabel.textAlignment = .right
            cell.messageLabel.textAlignment = .right
        }
        else if message.posterId == item.ownerId {
            cell.backgroundColor = UIColor(colorLiteralRed: 0.871, green: 0.788, blue: 0.38, alpha: 0.7664)     // Gold
            cell.nameLabel.textAlignment = .left
            cell.messageLabel.textAlignment = .left
        }
        else if message.posterId == message.adminId {
            cell.backgroundColor = UIColor(colorLiteralRed: 0.871, green: 0.788, blue: 0.38, alpha: 0.7664)     // Gold
            cell.nameLabel.textAlignment = .left
            cell.messageLabel.textAlignment = .left
        }
        else {
            cell.backgroundColor = UIColor.white
            cell.nameLabel.textAlignment = .left
            cell.messageLabel.textAlignment = .left
        }

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Functions
    
    func postMessage() {
        
        let inputController = UIAlertController(title: "Post Message", message: "What would you like to say?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let doneAction = UIAlertAction(title: "Post", style: .default) { inputAction in
            // post message
            if let text = inputController.textFields?[0].text, text.characters.count > 0 {
                HttpRequestManager.post(messageWithPosterId: AppDelegate.user?.userId ?? "", posterPassword: AppDelegate.user?.password ?? "", itemId: self.item.itemId, text: text) { message, response, error in
                    print("Message posted")
                    self.handleRefresh()
                }
            }
            else {
                inputController.title = "Text cannot be empty"
                self.present(inputController, animated: true, completion: nil)
            }
        }
        
        inputController.addTextField(configurationHandler: nil)
        inputController.addAction(cancelAction)
        inputController.addAction(doneAction)
        
        present(inputController, animated: true, completion: nil)
    }

    func handleRefresh() {
        HttpRequestManager.messages(forItemId: item.itemId) { messages, response, error in
            self.messages = messages
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                //self.tableView.setContentOffset(CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude), animated: false)
                if messages.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: false)
                }
            }
        }
    }
}
