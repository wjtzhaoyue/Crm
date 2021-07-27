package com.bjpowernode.crm.settings.web.controller;

import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.Impl.UserServiceImpl;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.utils.MD5Util;
import com.bjpowernode.crm.utils.PrintJson;
import com.bjpowernode.crm.utils.ServiceFactory;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class UserController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        System.out.println("进入到用户控制器");

        String path=request.getServletPath();

        if("/settings/user/login.do".equals(path)){
            login(request,response);


        }else  if("/settings/user/xxx.do".equals(path)){

        }

    }

    private void login(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到验证登陆操作");

        String loginAct=request.getParameter("loginAct");
        String loginPwd=request.getParameter("loginPwd");

        loginPwd= MD5Util.getMD5(loginPwd);

        String ip=request.getRemoteAddr();
        System.out.println("----------ip:"+ip);

        //!!!!!重要思想
        //未来  业务层开发，统一使用代理类形态的接口对象
        UserService us= (UserService) ServiceFactory.getService(new UserServiceImpl());

        try{
            User user=us.login(loginAct,loginPwd,ip);//  重要！！！！！！！要看明白为什么这里要调用方法的思想。
            //当调用login方法的时候出现了异常，会直接跳到catch语句中，那么下面的这句request将不会执行

            request.getSession().setAttribute("user",user);

           // {"success":true}
//            String  str="{\"success\":true}";
//            response.getWriter().print(str);
            PrintJson.printJsonFlag(response,true);
        }catch (Exception e) {
            e.printStackTrace();
            String msg=e.getMessage();
            //这时候，需要将登陆失败的 和 异常 这 两个信息传到前端ajax
           // 方法有两种：1 使用map ，将map'解析为json
               //        2 使用ov即创建新的组合类型对象，将需要传过去的信息组装为一个对象
            //  选择的时候，我们考虑是否会经常使用，若是经常使用我们就创建ov
            //否则就使用map，要不然会浪费空间
            Map<String ,Object> map=new HashMap<String, Object>();
            map.put("success",false);//这行可以不写
            map.put("msg",msg);
            PrintJson.printJsonObj(response,map);


        }

    }


}
