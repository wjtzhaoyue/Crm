package com.bjpowernode.crm.web.listener;

import com.bjpowernode.crm.settings.domain.DicValue;
import com.bjpowernode.crm.settings.service.DicService;
import com.bjpowernode.crm.settings.service.Impl.DicServiceImpl;
import com.bjpowernode.crm.utils.ServiceFactory;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.util.*;


//这里是监听器，监听的对象是：三大域对象的变化
//监听器其实也就象是一个controller

public class SysInitListener implements ServletContextListener {

    //当服务器一启动，就会自动创建上下文域对象。执行下面的方法。是创建的对象执行的方法。
    //监听的是什么对象，就能通过event得到该对象
    //例如我们这里监听的是 上下文域对象 ， 那么通过该参数就可以获得上下文域对象

    public void contextInitialized(ServletContextEvent event) {
        //System.out.println("上下文域对象创建了");//上下文域对象是application
        System.out.println("服务器缓存处理数据字典开始了");
        //
        ServletContext application=event.getServletContext();

        //DicService是字典相关的服务类
        DicService ds= (DicService) ServiceFactory.getService(new DicServiceImpl());

        //要理解List<DicValue>！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！1
                  Map<String, List<DicValue>> map= ds.getAll();

                  Set<String> set=map.keySet();
                  for(String key:set){
                      application.setAttribute(key,map.get(key));
                  }
        System.out.println("服务器缓存处理数据字典结束了");

                  //处理properties文件
        Map<String,String> pMap=new HashMap<>();//p 表示可能性。这里处理的是交易列表的可能性
        //Map<x,y>如果y写成object，那么在getAttribute的时候仍旧需要强转。这里写成string就不用强转
        ResourceBundle rb=ResourceBundle.getBundle("Stage2Possibility");
        Enumeration<String> e=rb.getKeys();
        while(e.hasMoreElements()){
            String key=e.nextElement();
            String value=rb.getString(key);
            pMap.put(key,value);//这里key！不能加""""""""""""""""""""""""""""""""'''
        }
        application.setAttribute("pMap",pMap);


    }

    public void contextDestroyed(ServletContextEvent event) {

    }
}
