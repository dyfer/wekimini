/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package wekimini.osc;

import com.illposed.osc.OSCMessage;
import com.illposed.osc.OSCPortOut;
import java.io.IOException;
import java.net.InetAddress;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author rebecca
 */
public class OSCSender {

    //Mapped to OSC OutputGroup ID
    private OSCPortOut sender = null;
    private InetAddress hostname = null;
    private int port = -1;
    private String sendMessage;
    private final String DEFAULT_SEND_MESSAGE = "/wek/outputs";
    private final int DEFAULT_SEND_PORT = 6453;
    private boolean isValidState = false;
    
    public boolean hasValidHostAndPort() {
        return isValidState;
    }
    
    public OSCSender() throws UnknownHostException, SocketException {
//        hostname = InetAddress.getByName("localhost");
//        port = DEFAULT_SEND_PORT;
        sendMessage = DEFAULT_SEND_MESSAGE;
//        sender = new OSCPortOut(hostname, port);
    }
    
    public OSCSender(InetAddress hostname, int port) throws SocketException {
        this.hostname = hostname;
        this.port = port;
        sendMessage = DEFAULT_SEND_MESSAGE;
        sender = new OSCPortOut(hostname, port);  
        isValidState = true;
    }
    
    public void setDefaultHostAndPort() throws SocketException, UnknownHostException {
        setHostnameAndPort(InetAddress.getByName("localhost"), DEFAULT_SEND_PORT);
    }
    
    public void setSendMessage(String sendMessage) throws SocketException {
        this.sendMessage = sendMessage;
        sender = new OSCPortOut(hostname, port);
    }
    
    public String getSendMessage() {
        return sendMessage;
    }

    public InetAddress getHostname() {
        return hostname;
    }

    public void setHostnameAndPort(InetAddress hostname, int port) throws SocketException {
        sender = new OSCPortOut(hostname, port);
        this.port = port;
        this.hostname = hostname;
        isValidState = true;
    }

    public int getPort() {
        return port;
    }
  
    

    //Does not establish long-term sender
    //Use for connection testing
    public static void sendTestMessage(String message, InetAddress hostname, int port, int numFloats) throws SocketException, IOException {
        OSCPortOut s = new OSCPortOut(hostname, port);
        Object[] o = new Object[numFloats];
        for (int i = 0; i < o.length; i++) {
            o[i] = new Float(i);
        }
        OSCMessage msg = new OSCMessage(message, o);
        s.send(msg);
    }


    public void sendOutputValuesMessage(double[] data) throws IOException {
        if (isValidState) {
            Object[] o = new Object[data.length];
            try {
                for (int i = 0; i < data.length; i++) {
                    o[i] = (float)data[i];
                }

                OSCMessage msg = new OSCMessage(sendMessage, o);
                sender.send(msg);
            } catch (IOException ex) {
                Logger.getLogger(OSCSender.class.getName()).log(Level.SEVERE, null, ex);
                throw ex;
            }
        } else {
            System.out.println("Could not send OSC message: Invalid state");
        }
        
    }

}
