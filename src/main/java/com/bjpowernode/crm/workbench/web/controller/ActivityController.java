package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.Impl.UserServiceImpl;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.utils.*;
import com.bjpowernode.crm.vo.PaginationVO;
import com.bjpowernode.crm.workbench.dao.ActivityRemarkDao;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.ActivityRemark;
import com.bjpowernode.crm.workbench.service.ActivityService;
import com.bjpowernode.crm.workbench.service.Impl.ActivityServiceImpl;


import javax.print.DocFlavor;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActivityController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        System.out.println("进入到市场活动控制器");

        String path=request.getServletPath();

        if("/workbench/activity/getUserList.do".equals(path)){

            getUserList(request,response);
        }else  if("/workbench/activity/save.do".equals(path)){
            save(request,response);

        }else  if("/workbench/activity/pageList.do".equals(path)){
            pageList(request,response);

        }else  if("/workbench/activity/delete.do".equals(path)){
            delete(request,response);
        }else  if("/workbench/activity/getUserListAndActivity.do".equals(path)){
            getUserListAndActivity(request,response);
        }else  if("/workbench/activity/update.do".equals(path)){
            update(request,response);
        }
        else  if("/workbench/activity/detail.do".equals(path)){
            detail(request,response);
        }else  if("/workbench/activity/getRemarkListByAid.do".equals(path)){
            getRemarkListByAid(request,response);
        }else  if("/workbench/activity/deleteRemark.do".equals(path)){
            deleteRemark(request,response);
        }else  if("/workbench/activity/saveRemark.do".equals(path)){
            saveRemark(request,response);
        }else  if("/workbench/activity/updateRemark.do".equals(path)){
            updateRemark(request,response);
        }


    }

    //这个是更改备注并保存
    private void updateRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("执行修改备注的操作");


       String id= request.getParameter("id");
       String noteContent=request.getParameter("noteContent");

        String editTime=DateTimeUtil.getSysTime();
        String editBy=((User)request.getSession().getAttribute("user")).getName();

        String editFlag="1";

        ActivityRemark ar=new ActivityRemark();

        ar.setId(id);//这里之所以设置id是为了将ar传回后端数据库，根据id进行修改操作
        ar.setNoteContent(noteContent);
        ar.setEditTime(editTime);
        ar.setEditBy(editBy);
        ar.setEditFlag(editFlag);

        ActivityService as= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        boolean flag=as.updateRemark(ar); //这里使用动态代理，所以接着要去Service接口中写方法


        Map<String,Object> map=new HashMap<String, Object>();
        map.put("ar",ar);
        map.put("success",flag);

        PrintJson.printJsonObj(response,map);

    }
//这个是首次创建备注
    private void saveRemark(HttpServletRequest request, HttpServletResponse response) {
        String noteContent = request.getParameter("noteContent");
                String activityId = request.getParameter("activityId");
                String createTime=DateTimeUtil.getSysTime();
                String createBy=((User)request.getSession().getAttribute("user")).getName();
                String id = UUIDUtil.getUUID();
                String editFlag="0";

                ActivityRemark ar=new ActivityRemark();

                ar.setActivityId(activityId);
                ar.setNoteContent(noteContent);
                ar.setCreateTime(createTime);
                ar.setCreateBy(createBy);
                ar.setEditFlag(editFlag);
                ar.setId(id);

                ActivityService as= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

                boolean flag=as.saveRemark(ar);//这里使用动态代理，所以接着要去Service接口中写方法
                Map<String,Object> map=new HashMap<String, Object>();
                map.put("ar",ar);
                map.put("success",flag);

                PrintJson.printJsonObj(response,map);

    }

    private void deleteRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("删除备注的操作");
        String id=request.getParameter("id");

        ActivityService as= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        boolean flag=as.deleteRemark(id);
        PrintJson.printJsonFlag(response,flag);

    }

    private void getRemarkListByAid(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("根据活动id，取得备注信息列表");
        String activityId=request.getParameter("activityId");

        ActivityService as= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        List<ActivityRemark> arList =as.getRemarkListByAid(activityId);
        PrintJson.printJsonObj(response,arList);
    }

    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("跳转到详细信息页面的操作");
        String  id =request.getParameter("id");

        ActivityService as= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        Activity a=as.detail(id);


        request.setAttribute("a",a);

        request.getRequestDispatcher("/workbench/activity/detail.jsp").forward(request,response);

    }


    private void update(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("执行市场活动修改操作");
        //下面还是赋值添加操作的，然后进行了修改
        String id=request.getParameter("id");
        String owner = request.getParameter("owner");
        String  name = request.getParameter("name");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String  cost= request.getParameter("cost");
        String  description= request.getParameter("description");

        String editTime= DateTimeUtil.getSysTime();
        String editBy=((User)request.getSession().getAttribute("user")).getName();

        Activity activity=new Activity();

        activity.setId(id);
        activity.setOwner(owner);
        activity.setName(name);
        activity.setStartDate(startDate);
        activity.setEndDate(endDate);
        activity.setCost(cost);
        activity.setDescription(description);
        activity.setEditTime(editTime);
        activity.setEditBy(editBy);

        ActivityService as= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        boolean flag=as.update(activity);
        PrintJson.printJsonFlag(response,flag);




    }

    private void getUserListAndActivity(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("进入到查询用户信息和根据市场活动id查询单条记录的操作");

        String id=request.getParameter("id");
        //这里使用的还是Activity代理。正在这个代理的方法里面再使用接口中的方法
        ActivityService as= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        Map<String,Object> map=as.getUserListAndActivity(id);
        PrintJson.printJsonObj(response,map);

    }

    private void delete(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("执行市场活动的删除操作");

        String ids[] =request.getParameterValues("id");//这里的id是地址栏中传过来的id！！！！！!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!！！！！！！！！！！！

        ActivityService as= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        boolean flag=as.delete(ids);

        PrintJson.printJsonFlag(response,flag);

    }


    private void pageList(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("进入到查询市场活动信息列表的操作（结合条件查询+分页）");

        String  pageNoStr =request.getParameter("pageNo");
        String  pageSizeStr =request.getParameter("pageSize");
        String  owner=request.getParameter("owner");
        String  name=request.getParameter("name");
        String  startDate =request.getParameter("startDate");
        String  endDate =request.getParameter("endDate");

        //计算按页展示时候 跳过的条数

        int pageNo=Integer.valueOf(pageNoStr);
        int pageSize=Integer.valueOf(pageSizeStr);
        int skipCount=(pageNo-1)*pageSize;

        Map<String,Object> map=new HashMap<String, Object>();
        map.put("skipCount",skipCount);//这里是为sql语句中的limit 分页 做准备。即 这里是一个整数，将前端传送过来的当前页码。转化为要滤过的数目
        map.put("pageSize",pageSize);//这里也是一个整数。

        map.put("name",name);
        map.put("owner",owner);
        map.put("startDate",startDate);
        map.put("endDate",endDate);

        ActivityService as= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        //因为前端的导航页面有很多菜单都会用到这个分页操作的返回值，所以考虑将其封装为一个新的组装的类。
        //类  有两个属性：1 是 total 。2 是 List集合

        //这里前端现需要的返回值是：1.查询到的总条数 和 2 . 活动的list集合
       // 所以这里使用vo 。注意：vo是从后端向前端传输数据的时候才考虑使用。
        //前端向后端传是使用map


        PaginationVO<Activity> vo =as.pageList(map);

        PrintJson.printJsonObj(response,vo);


    }

    private void save(HttpServletRequest request, HttpServletResponse response) {
         System.out.println("执行市场活动添加操作");

        String id= UUIDUtil.getUUID();
        String owner = request.getParameter("owner");
        String  name = request.getParameter("name");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String  cost= request.getParameter("cost");
        String  description= request.getParameter("description");

        String creatTime= DateTimeUtil.getSysTime();
        String creatBy=((User)request.getSession().getAttribute("user")).getName();

        Activity activity=new Activity();

        activity.setId(id);
        activity.setOwner(owner);
        activity.setName(name);
        activity.setStartDate(startDate);
        activity.setEndDate(endDate);
        activity.setCost(cost);
        activity.setDescription(description);
        activity.setCreateTime(creatTime);
        activity.setCreateBy(creatBy);

        ActivityService as= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        try {
            boolean flag=as.save(activity);
            PrintJson.printJsonFlag(response,flag);
        } catch (Exception e) {
            e.printStackTrace();
            String msg=e.getMessage();
            Map<String ,Object> map=new HashMap<String, Object>();
            map.put("success",false);//这行可以不写
            map.put("msg",msg);
            PrintJson.printJsonObj(response,map);

        }


    }

    private void getUserList(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("获得用户信息列表");
        UserService us= (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> uList=us.getUserList();

        PrintJson.printJsonObj(response,uList);
    }


}
