import UIKit
import SocketIO
 
class ViewController: UIViewController {
 
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var chatContentTextView: UITextView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userList: UITextView!
    var i = 0
    let hostString: String = "http://localhost:7000"
    var socket : SocketIOClient? = nil
    var manager: SocketManager? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let hostUrl = URL(string: self.hostString)
        
        self.manager = SocketManager(socketURL: hostUrl!)
        self.socket = self.manager?.defaultSocket
          
   //將event和callback func綁在一起
        self.socket!.onAny(anyEventCallBack)
        
        self.socket!.on("connect",callback: connectCallBack)
             
        self.socket!.on("show message on screen", callback: serverMsgCallBack)
        
        self.socket!.on("show all socket list", callback: showAllCallBack)
        
    }
    
    func anyEventCallBack( anyEvent: SocketAnyEvent){
        
    }
    func connectCallBack( data:[Any], ack:SocketAckEmitter)
    {
        print("--- socket connected ---")
        let deadLine = DispatchTime.now() + .milliseconds(500)
        
        DispatchQueue.main.asyncAfter(deadline: deadLine) {
            //􏰴􏰱socket􏲨􏲩 event + message 􏲮server
            //self.socket!.emit("user send out message", "Hello! I've connected!")
            
        }
        self.socket!.emit("connect", self.userName.text as! String)
        
    }
 
//發訊息給server並收到server傳回來的訊息時，將其append在text view原本的內容後面
    func serverMsgCallBack( data:[Any], ack:SocketAckEmitter)
    {
        print("--- receive \"show message on screen\" event ---")
        //􏰵􏰛message string
        let message: String = (data[0] as! String)
    
        print("received:\n\n" + "\(message)" + "\n")
        
        let newChatContent = "\(message)\n\(self.chatContentTextView.text!)"
        self.chatContentTextView.text = newChatContent
        
    }
    //將收到的member list顯示出來
    func showAllCallBack( data:[Any], ack:SocketAckEmitter){
        self.userList.text = ""
        let message: String = (data[0] as! String)
        self.userList.text = message
    }
    
 //按下connect按鈕後進行connect
    @IBAction func connectButton(_ sender: Any) {
        
        print("--- connecting to \(self.hostString) —")
             
        self.socket!.connect()
        
    }
//按下disconnect按鈕後進行connect
    @IBAction func disconnectButton(_ sender: Any) {
        //self.socket!.emit("disconnect")
        self.socket!.disconnect();
    }

//按下send按鈕後寄出訊息
    @IBAction func sendButtonPressed(_ sender: Any) {
        let message = self.messageTextField.text!
        
        //self.i = self.i + 1
        
        //let newChatContent = "[\(self.i)] \(message)\n\(self.chatContentTextView.text!)"
        
        //self.chatContentTextView.text = newChatContent
        self.socket!.emit("user send out message", message)
        self.messageTextField.text = ""
    }
    
}
