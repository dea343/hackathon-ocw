//
//  CommentViewController.swift
//  iosclient
//
//  Created by 典 杨 on 16/4/8.
//  Copyright © 2016年 典 杨. All rights reserved.
//

import UIKit
import Alamofire

class CommentViewController: UITableViewController {
    
    var courseId: Int!
    var comments: NSMutableArray = []
    var Comments:[Comment] = []
    
    @IBOutlet var commentsView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getCourseItem:", name: "courseIdNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newComment:", name: "newCommentNotification", object: nil)
        //load comments
        loadCommentsFromUrl()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(commentsView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func tableView(commentsView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = commentsView.dequeueReusableCellWithIdentifier("CommentsCell") as! CommentsViewCell
        
        if let nameLabel = cell.viewWithTag(201) as? UILabel {
            nameLabel.text = comments[indexPath.row].valueForKey("author_name") as? String
        }
        
        if let commentLabel = cell.viewWithTag(202) as? UILabel {
            commentLabel.text = comments[indexPath.row].valueForKey("text") as? String
        }
        
        if let likeLabel = cell.viewWithTag(203) as? UILabel {
            likeLabel.text = String(comments[indexPath.row].valueForKey("like")!) as? String
        }
        
        if(comments[indexPath.row].valueForKey("headimgurl") != nil)
        {
            if let userImageView = cell.viewWithTag(200) as? UIImageView {
                let URLString:NSURL = NSURL(string: comments[indexPath.row].valueForKey("headimgurl") as! String)!
                userImageView.sd_setImageWithURL(URLString, placeholderImage: UIImage(named: "default.jpg"))
                userImageView.layer.borderWidth = 2
                userImageView.layer.masksToBounds = false
                userImageView.layer.borderColor = UIColor.whiteColor().CGColor
                userImageView.layer.cornerRadius = userImageView.frame.height/2
                userImageView.clipsToBounds = true
            }
        
        }
        return cell
    }
    
    func loadCommentsFromUrl(){
        //let url = NSURL(string: "http://jieko.cc/item/" + String(courseId!) + "/Comments")
        let url = NSURL(string: "http://jieko.cc/item/" + String("1") + "/Comments")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()){(response, data, error) in self.startCommentsParsing(data!)
        }
    }
    
    //Handler
    func getCourseItem(notif: NSNotification) {
        courseId = notif.userInfo!["courseId"] as! Int
    }
    
    func newComment(notif: NSNotification){
        let newComment: NSMutableDictionary = notif.userInfo!["newComment"] as! NSMutableDictionary
        newComment.setValue(0, forKey: "like")
        newComment.setValue(User.sharedManager.userid, forKey: "author_id")
        if(User.sharedManager.nickname != nil){
            newComment.setValue(User.sharedManager.nickname, forKey: "author_name")
            newComment.setValue(User.sharedManager.headimgurl, forKey: "headimgurl")
        }
        comments.insertObject(newComment, atIndex: 0)
        commentsView.reloadData()
    }
    
    func startCommentsParsing(data: NSData){
        let dict: NSArray!=(try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)) as! NSArray
        for i in 0...(dict.count - 1){
            comments.addObject(dict.objectAtIndex(i))
            var newComment = Comment()
            let commentDic: NSDictionary = dict.objectAtIndex(i) as! NSDictionary
            newComment.item_id = commentDic["item_id"]?.integerValue
            newComment.author_id = commentDic["author_id"]?.integerValue
            newComment.author_name = commentDic["author_name"] as? String
            newComment.text = commentDic["text"] as? String
            newComment.posted = commentDic["posted"] as? String
            newComment.timeline = commentDic["timeline"]?.integerValue
            newComment.like = commentDic["like"]?.integerValue
            Comments.append(newComment)
        }
        commentsView.reloadData()
        loadHeadImg()
    }
    
    
    func loadHeadImg(){
        for comment in comments {
            
            let commentDic: NSDictionary = comment as! NSDictionary
            let author_id: Int! = commentDic["author_id"]?.integerValue
            
            Alamofire.request(.GET, "http://jieko.cc/user/" + String(author_id!)).responseJSON { response in
                print(response.result)   // result of response serialization
                print(response.result.value)
                
                if let JSON = response.result.value as? Array<Dictionary<String, AnyObject>> {
                    self.comments.removeObject(comment)
                    let headimgurl: String = (JSON[0]["headimgurl"] as? String)!
                    print(headimgurl)
                    commentDic.setValue(headimgurl, forKey: "headimgurl")
                    self.comments.addObject(commentDic)
                    self.commentsView.reloadData()
                }
            }
        }
    }

    
}