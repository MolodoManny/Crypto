//
//  ContentView.swift
//  Crypto
//
//  Created by Артем Савицкий on 29.06.2022.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth






    

struct ContentView: View {
    
        @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
        
        var body: some View {
            
            VStack{
                
                if status{
                    
                    Home()
                }
                else{
                    
                    Sign_In()
                }
                
            }.animation(.spring())
                .onAppear {
                    
                    NotificationCenter.default.addObserver(forName: NSNotification.Name("statusChange"), object: nil, queue: .main) { (_) in
                        
                        let status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
                        self.status = status
                    }
            }
        }
    }


struct NewButtonStyle : ButtonStyle{
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(30)
            .background(
        Capsule()
            .fill(Color.yellow)
            .shadow(color: Color.blue.opacity(0.2), radius: 10, x: 10, y: 10)
                        .shadow(color: Color.yellow.opacity(0.7), radius: 10, x: -5, y: -5)
        )
    }
}

struct Home : View{
    var body: some View{
        VStack{
            Text("Home")
            Button(action:{
                UserDefaults.standard.set(false , forKey: "status")
                NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
            }){
            Text("log")
        }
        }
    }
}


struct Sign_In : View{
    @State var user = ""
    @State var pass = ""
    @State var message = ""
    @State var alert = false
    @State var show = false
    var body: some View{
        VStack{
            Text(" Crypasto").fontWeight(.heavy).font(.largeTitle).foregroundColor(.yellow).padding(.bottom)
        }
            VStack{
                Text("Sign In").fontWeight(.heavy).font(.largeTitle).padding([.top,.bottom], 20).buttonStyle(NewButtonStyle())
                
                VStack(alignment: .leading){
                    
                    VStack(alignment: .leading){
                        
                        Text("Username").font(.headline).fontWeight(.light).foregroundColor(Color.init(.label).opacity(0.75))
                        
                        HStack{
                            
                            TextField("Enter Your Username", text: $user)
                            
                            if user != ""{
                                
                                Image("check").foregroundColor(Color.init(.label))
                            }
                            
                        }
                        
                        Divider()
                        
                    }.padding(.bottom, 15)
                    
                    VStack(alignment: .leading){
                        
                        Text("Password").font(.headline).fontWeight(.light).foregroundColor(Color.init(.label).opacity(0.75))
                        
                        SecureField("Enter Your Password", text: $pass)
                        
                        Divider()
                    }
                    
                }.padding(.horizontal, 6)
                
                Button(action: {
                                   print("Sign In")
                                   signInWithEmail(email: self.user, password: self.pass) { (verified, status) in
                                       
                                       if !verified {
                                           
                                           self.message = status
                                           self.alert.toggle()
                                       }
                                       else{
                                           
                                           UserDefaults.standard.set(true, forKey: "status")
                                           NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                                       }
                                   }
                                   
                }){
                    Image("Circle").frame(width: 100, height: 50).clipped().clipShape(Capsule()).padding(30)
                        .buttonStyle(NewButtonStyle())
                    
                } .alert(isPresented: $alert) {
                    
                    Alert(title: Text("Error"), message: Text(self.message), dismissButton: .default(Text("Ok")))
            }
                
                HStack(spacing : 8){
                    Text("Dont have account?").fontWeight(.medium).foregroundColor(.gray).padding()
                }
        Button(action: {
                               
                               self.show.toggle()
                               
                           })
        {
            Text("Sign Up")/*.buttonStyle(.bordered).foregroundColor(.black).font(.headline).background(.yellow).clipShape(Capsule())*/
                .buttonStyle(NewButtonStyle())
        }.sheet(isPresented: $show) {
            
            Sign_Up(show: self.show)
        }
        }
    }
}



struct Sign_Up : View{
    
    @State var user = ""
    @State var pass = ""
    @State var message = ""
    @State var alert = false
    @State var show = false
    
    var body: some View{
        VStack{
            Text("Sign Up").fontWeight(.heavy).font(.largeTitle).padding([.top,.bottom], 20)
            
            VStack(alignment: .leading){
                
                VStack(alignment: .leading){
                    
                    Text("Username").font(.headline).fontWeight(.light).foregroundColor(Color.init(.label).opacity(0.75))
                    
                    HStack{
                        
                        TextField("Enter Your Username", text: $user)
                        
                        if user != ""{
                            
                            Image("check").foregroundColor(Color.init(.label))
                        }
                        
                    }
                    
                    Divider()
                    
                }.padding(.bottom, 15)
                
                VStack(alignment: .leading){
                    
                    Text("Password").font(.headline).fontWeight(.light).foregroundColor(Color.init(.label).opacity(0.75))
                    
                    SecureField("Enter Your Password", text: $pass)
                    
                    Divider()
                }
                
            }.padding(.horizontal, 6)
            
            VStack{
                Button(action: {
                                   
                    signUpWithEmail(email: self.user, password: self.pass) { (verified, status) in
                                       
                                       if !verified {
                                           
                                           self.message = status
                                           self.alert.toggle()
                                       }
                                       else{
                                           
                                           UserDefaults.standard.set(true, forKey: "status")
                                           NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                                       }
                                   }
                                   
                }) {
                    Text("Sign Up").buttonStyle(.bordered).foregroundColor(.black).font(.headline).background(RoundedRectangle(cornerRadius: 100).strokeBorder()).clipShape(Capsule())
                    
                }
                .alert(isPresented: $alert) {
                                
                                Alert(title: Text("Error"), message: Text(self.message), dismissButton: .default(Text("Ok")))
                        }
            }
    }
}
}





func signInWithEmail(email: String,password : String,completion: @escaping (Bool,String)->Void){
    
    Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
        
        if err != nil{
            
            completion(false,(err?.localizedDescription)!)
            return
        }
        
        completion(true,(res?.user.email)!)
    }
}

func signUpWithEmail(email: String,password : String,completion: @escaping (Bool,String)->Void){
    
    Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
        
        if err != nil{
            
            completion(false,(err?.localizedDescription)!)
            return
        }
        
        completion(true,(res?.user.email)!)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


//github!!!
