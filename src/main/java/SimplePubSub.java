// SCCSID "@(#) MQMBID sn=p750-007-160812 su=_Q7L2EGB5EeavWqNpgfWvaA pn=MQJavaSamples/jms/simple/SimplePubSub.java"
/*
 *   <copyright 
 *   notice="lm-source-program" 
 *   pids="5724-H72,5655-R36,5655-L82,5724-L26," 
 *   years="2008,2012" 
 *   crc="3812808746" > 
 *  Licensed Materials - Property of IBM  
 *   
 *  5724-H72,5655-R36,5655-L82,5724-L26, 
 *   
 *  (C) Copyright IBM Corp. 2008, 2012 All Rights Reserved.  
 *   
 *  US Government Users Restricted Rights - Use, duplication or  
 *  disclosure restricted by GSA ADP Schedule Contract with  
 *  IBM Corp.  
 *   </copyright> 
 */


import javax.jms.Connection;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.MessageProducer;
import javax.jms.Session;
import javax.jms.TextMessage;

import com.ibm.msg.client.jms.JmsConnectionFactory;
import com.ibm.msg.client.jms.JmsFactoryFactory;
import com.ibm.msg.client.wmq.WMQConstants;

/**
 * A minimal and simple application for Publish-Subscribe messaging.
 * 
 * Application makes use of fixed literals, any customisations will require re-compilation of this
 * source file.
 * 
 * Notes:
 * 
 * API type: JMS API (v1.1, unified domain)
 * 
 * Messaging domain: Publish-Subscribe
 * 
 * Provider type: WebSphere MQ
 * 
 * Connection mode: Client connection
 * 
 * JNDI in use: No
 * 
 */
public class SimplePubSub {

  // System exit status value (assume unset value to be 1)
  private static int status = 1;

  /**
   * Main method
   * 
   * @param args
   */
  public static void main(String[] args) throws InterruptedException {

    // Variables
    Connection connection = null;
    Session session = null;
    Destination destination = null;
    MessageProducer producer = null;
    MessageConsumer consumer = null;

    try {
      // Create a connection factory
      JmsFactoryFactory ff = JmsFactoryFactory.getInstance(WMQConstants.WMQ_PROVIDER);
      JmsConnectionFactory cf = ff.createConnectionFactory();

      // Set the properties
      cf.setStringProperty(WMQConstants.WMQ_HOST_NAME, "ibmmq");
      cf.setIntProperty(WMQConstants.WMQ_PORT, 1414);
      cf.setStringProperty(WMQConstants.WMQ_CHANNEL, "DEV.ADMIN.SVRCONN");
      cf.setIntProperty(WMQConstants.WMQ_CONNECTION_MODE, WMQConstants.WMQ_CM_CLIENT);
      cf.setStringProperty(WMQConstants.WMQ_QUEUE_MANAGER, "QM1");
//      cf.setStringProperty(WMQConstants.WMQ_SSL_CIPHER_SUITE, "SSL_RSA_WITH_AES_256_GCM_SHA384");
//      cf.setStringProperty(WMQConstants.WMQ_SSL_CIPHER_SPEC, "TLS_RSA_WITH_AES_256_GCM_SHA384");

      // Create JMS objects
      connection = cf.createConnection("admin","passw0rd");
      session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
      destination = session.createTopic("topic://foo");
      producer = session.createProducer(destination);
      consumer = session.createConsumer(destination);

      long uniqueNumber = System.currentTimeMillis() % 1000;
      TextMessage message = session.createTextMessage("SimplePubSub: Your lucky number today is "
          + uniqueNumber);

      // Start the connection
      connection.start();

      // And, send the message
      producer.send(message);
      System.out.println("Sent message:\n" + message);

      Thread.sleep(30000);

      Message receivedMessage = consumer.receive(1500000); // in ms or 15 seconds
      System.out.println("\nReceived message:\n" + receivedMessage);

      recordSuccess();
    }
    catch (JMSException jmsex) {
      recordFailure(jmsex);
    }
    finally {
      if (producer != null) {
        try {
          producer.close();
        }
        catch (JMSException jmsex) {
          System.out.println("Producer could not be closed.");
          recordFailure(jmsex);
        }
      }
      if (consumer != null) {
        try {
          consumer.close();
        }
        catch (JMSException jmsex) {
          System.out.println("Consumer could not be closed.");
          recordFailure(jmsex);
        }
      }

      if (session != null) {
        try {
          session.close();
        }
        catch (JMSException jmsex) {
          System.out.println("Session could not be closed.");
          recordFailure(jmsex);
        }
      }

      if (connection != null) {
        try {
          connection.close();
        }
        catch (JMSException jmsex) {
          System.out.println("Connection could not be closed.");
          recordFailure(jmsex);
        }
      }
    }
    System.exit(status);
    return;
  } // end main()

  /**
   * Process a JMSException and any associated inner exceptions.
   * 
   * @param jmsex
   */
  private static void processJMSException(JMSException jmsex) {
    System.out.println(jmsex);
    Throwable innerException = jmsex.getLinkedException();
    if (innerException != null) {
      System.out.println("Inner exception(s):");
    }
    while (innerException != null) {
      System.out.println(innerException);
      innerException = innerException.getCause();
    }
    return;
  }

  /**
   * Record this run as successful.
   */
  private static void recordSuccess() {
    System.out.println("SUCCESS");
    status = 0;
    return;
  }

  /**
   * Record this run as failure.
   * 
   * @param ex
   */
  private static void recordFailure(Exception ex) {
    if (ex != null) {
      if (ex instanceof JMSException) {
        processJMSException((JMSException) ex);
      }
      else {
        System.out.println(ex);
      }
    }
    System.out.println("FAILURE");
    status = -1;
    return;
  }

}
