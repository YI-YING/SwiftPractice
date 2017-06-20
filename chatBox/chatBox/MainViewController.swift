//
//  MainViewController.swift
//  chatBox
//
//  Created by MCUCSIE on 6/14/17.
//  Copyright © 2017 MCUCSIE. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseDatabase

class MainViewController: JSQMessagesViewController {

    @IBOutlet weak var navigationbar: UINavigationBar!

    var navigationBarTitle: String!         // Use to get title
    var friendID: String!                   // Use to get friend ID
    var messages = [JSQMessage]()           // Use to save messages
    var chatRoomPath: DatabaseReference?    // Get chat room path

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        getMessages()
    }

    // MARK: - collection

    // Return a value to indicate how many messages are in this conversasion
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    // Return message content at the row
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }

    // Return the outlet of message
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        let message = messages[indexPath.row]

        if message.senderId == self.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: .blue)
        }

        return bubbleFactory?.incomingMessagesBubbleImage(with: .green)
    }

    // Return head picture of message
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }

    // Return display label name of message
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        let userName = message.senderDisplayName

        return NSAttributedString(string: userName!)
    }

    // Return label name's height
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }

    // This method will be call after Send button is pressed
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {

        let message = ["senderID": senderId,
                       "displayName": senderDisplayName,
                       "text": text] as [String : String];
        let time = date.timeIntervalSince1970 as Double
        let newNode = String(format: "%.0f", time * 1000)

        self.chatRoomPath?.child(newNode).setValue(message)
    }



    // MARK: - method
    
    func getMessages() {
        let chatRoomID = self.senderId > self.friendID ? self.senderId + self.friendID :
            self.friendID + self.senderId

        self.chatRoomPath = Database.database().reference().child("/messages/\(chatRoomID)")
        self.chatRoomPath?.queryOrderedByKey().observe(.value, with: { (snapShot) in
            if !snapShot.hasChildren() {
                return
            }

            let messagesArray = snapShot.children.allObjects as! [DataSnapshot]

            self.messages.removeAll()
            for snap in messagesArray {
                let message = snap.value as! [String: String]

                let jsqMessage = JSQMessage(senderId: message["senderID"],
                                            displayName: message["displayName"],
                                            text: message["text"])
                self.messages.append(jsqMessage!)
            }
            self.finishSendingMessage()
        })
    }

    func setupNavigationBar() {
        self.view.addSubview(self.navigationbar)
        self.navigationbar.topItem?.title = self.navigationBarTitle
        self.navigationbar.frame = CGRect(x: 0, y: 0, width: 375, height: 64)
        self.topContentAdditionalInset = 64
    }

    @IBAction func cancel() {
        self.chatRoomPath?.removeAllObservers()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}
