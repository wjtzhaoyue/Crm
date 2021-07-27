package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.Impl.UserServiceImpl;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.PrintJson;
import com.bjpowernode.crm.utils.ServiceFactory;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.vo.PaginationVO;
import com.bjpowernode.crm.workbench.domain.*;

import com.bjpowernode.crm.workbench.service.ActivityService;
import com.bjpowernode.crm.workbench.service.ClueService;
import com.bjpowernode.crm.workbench.service.Impl.ActivityServiceImpl;
import com.bjpowernode.crm.workbench.service.Impl.ClueServiceImpl;


import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ClueController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        System.out.println("进入到线索控制器");

        String path = request.getServletPath();

        if ("/workbench/clue/getUserList.do".equals(path)) {
            getUserList(request,response);
        } else if ("/workbench/clue/save.do".equals(path)) {
            save(request,response);
        } else if ("/workbench/clue/pageList.do".equals(path)) {
            pageList(request,response);
        } else if ("/workbench/clue/detail.do".equals(path)) {
            detail(request,response);
        }else if ("/workbench/clue/getAcitivityListByClueId.do".equals(path)) {
            getAcitivityListByClueId(request,response);
        }else if ("/workbench/clue/getUserListAndClue.do".equals(path)) {
            getUserListAndClue(request,response);
        }else if ("/workbench/clue/update.do".equals(path)) {
            update(request,response);
        }else if ("/workbench/clue/getRemarkListByCid.do".equals(path)) {
            getRemarkListByCid(request,response);
        }else if ("/workbench/clue/updateRemark.do".equals(path)) {
            updateRemark(request,response);
        }else if ("/workbench/clue/deleteRemark.do".equals(path)) {
            deleteRemark(request,response);
        }else if ("/workbench/clue/saveRemark.do".equals(path)) {
            saveRemark(request,response);
        }else if ("/workbench/clue/unbind.do".equals(path)) {
            unbind(request,response);
        }else if ("/workbench/clue/getActivityByNameAndNotByClueId.do".equals(path)) {
            getActivityByNameAndNotByClueId(request,response);
        }else if ("/workbench/clue/guanlian.do".equals(path)) {
            guanlian(request,response);
        }else if ("/workbench/clue/getActivityByName.do".equals(path)) {
            getActivityByName(request,response);
        }else if ("/workbench/clue/convert.do".equals(path)) {
            convert(request,response);
        }else if ("/workbench/clue/delete.do".equals(path)) {
            delete(request,response);
        }else if ("/workbench/clue/getChar.do".equals(path)) {
            getChar(request,response);
        }
    }

    private void getChar(HttpServletRequest request, HttpServletResponse response) {
        ClueService cs= (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        Map<String,Object> map=cs.getCharts();
        PrintJson.printJsonObj(response,map);
    }

    //这里是再index页面的删除线索。并不会进行转换操作，支持批量删除
    private void delete(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到index的批量删除页面操作，不会进行转换");
        String ids[] =request.getParameterValues("id");
        ClueService cs= (ClueService) ServiceFactory.getService(new ClueServiceImpl());

        boolean flag=cs.delete(ids);

        PrintJson.printJsonFlag(response,flag);

    }

    private void convert(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进行线索转换的操作");
        String clueId=request.getParameter("clueId");
        String flag=request.getParameter("flag");
        //注意为什么createBy要传递出去。因为需要业务分离。在serviceimpl中需要创建表。而且完善数据库内容，但是在serviceimpl中使用request显得太乱。。
        String createBy=((User)request.getSession().getAttribute("user")).getName();
        Tran t =null;
        //思想很重要!!!!! 这里在form表单中设置的标签，很好。因为用户可能随机填了几个选项。所以你不确定那个选项被填了，所以你只能自己加上一个标记!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
        if("a".equals(flag)){
            //走到这里说明是提交了表单过来了。需要创建交易
            t=new Tran();
            String money=request.getParameter("money");
            String name=request.getParameter("name");
            String expectedDate=request.getParameter("expectedDate");
            String activityId=request.getParameter("activityId");
            String stage=request.getParameter("stage");
            String id=UUIDUtil.getUUID();

            String createTime=DateTimeUtil.getSysTime();

            t.setId(id);
            t.setMoney(money);
            t.setName(name);
            t.setExpectedDate(expectedDate);
            t.setActivityId(activityId);
            t.setStage(stage);
            t.setCreateTime(createTime);
            t.setCreateBy(createBy);

        }
        ClueService cs= (ClueService) ServiceFactory.getService(new ClueServiceImpl());

        boolean flag1=cs.convert(clueId,t,createBy);
        if(flag1){
            response.sendRedirect(request.getContextPath()+"/workbench/clue/index.jsp");
        }



    }

    private void getActivityByName(HttpServletRequest request, HttpServletResponse response) {
        String aname=request.getParameter("aname");
        ClueService cs= (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        List<Activity> aList=cs.getActivityByName(aname);
        PrintJson.printJsonObj(response,aList);
    }

    private void guanlian(HttpServletRequest request, HttpServletResponse response) {
        String cid=request.getParameter("cid");
        String[] aids=request.getParameterValues("aid");

        ClueService cs= (ClueService) ServiceFactory.getService(new ClueServiceImpl());
       //!!!!!!注意不在controller中处理aids！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
       boolean flag=cs.guanlian(cid,aids);
       PrintJson.printJsonFlag(response,flag);
    }

    private void getActivityByNameAndNotByClueId(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到绑定活动中的查询活动的操作");
        String clueId =request.getParameter("clueId");
        String  aname=request.getParameter("aname");

        Map<String ,String> map=new HashMap<String, String>();
        map.put("clueId",clueId);
        map.put("aname",aname);

        ClueService cs= (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        List<Activity> list=cs.getActivityByNameAndNotByClueId(map);
        PrintJson.printJsonObj(response,list);

    }

    private void unbind(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到线索中的活动取消绑定操作");
        String id=request.getParameter("id");
        ClueService cs= (ClueService) ServiceFactory.getService(new ClueServiceImpl());

        boolean flag=cs.unbind(id);

        PrintJson.printJsonFlag(response,flag);

    }

    private void saveRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到线索中的 备注添加操作");
        String noteContent = request.getParameter("noteContent");
        String clueId = request.getParameter("clueId");
        String createTime=DateTimeUtil.getSysTime();
        String createBy=((User)request.getSession().getAttribute("user")).getName();
        String id = UUIDUtil.getUUID();
        String editFlag="0";

        ClueRemark cr=new ClueRemark();

        cr.setClueId(clueId);
        cr.setNoteContent(noteContent);
        cr.setCreateTime(createTime);
        cr.setCreateBy(createBy);
        cr.setEditFlag(editFlag);
        cr.setId(id);

        ClueService cs= (ClueService) ServiceFactory.getService(new ClueServiceImpl());

        boolean flag=cs.saveRemark(cr);//这里使用动态代理，所以接着要去Service接口中写方法
        Map<String,Object> map=new HashMap<String, Object>();
        map.put("cr",cr);
        map.put("success",flag);

        PrintJson.printJsonObj(response,map);

    }

    private void deleteRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("删除备注的操作");
        String id=request.getParameter("id");

       ClueService cs= (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        boolean flag=cs.deleteRemark(id);
        PrintJson.printJsonFlag(response,flag);
    }

    private void updateRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到更改线索的备注信息操作");
        String id= request.getParameter("id");
        String noteContent=request.getParameter("noteContent");

        String editTime=DateTimeUtil.getSysTime();
        String editBy=((User)request.getSession().getAttribute("user")).getName();

        String editFlag="1";

        ClueRemark cr=new ClueRemark();

        cr.setId(id);//这里之所以设置id是为了将ar传回后端数据库，根据id进行修改操作
        cr.setNoteContent(noteContent);
        cr.setEditTime(editTime);
        cr.setEditBy(editBy);
        cr.setEditFlag(editFlag);

        ClueService as= (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        boolean flag=as.updateRemark(cr); //这里使用动态代理，所以接着要去Service接口中写方法


        Map<String,Object> map=new HashMap<String, Object>();
        map.put("cr",cr);
        map.put("success",flag);

        PrintJson.printJsonObj(response,map);




    }

    private void getRemarkListByCid(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到根据线索id找到对应的全部备注信息");

        String clueId=request.getParameter("clueId");

        ClueService cs= (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        List<ClueRemark> crList =cs.getRemarkListByCid(clueId);
        PrintJson.printJsonObj(response,crList);
    }

    private void update(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到线索更新操作");
        String id=request.getParameter("id");
        String  owner=request.getParameter("owner");
        String  company=request.getParameter("company");
        String  appellation=request.getParameter("appellation");
        String  fullname=request.getParameter("fullname");
        String  job=request.getParameter("job");
        String  email=request.getParameter("email");
        String  phone=request.getParameter("phone");
        String  website=request.getParameter("website");
        String  mphone=request.getParameter("mphone");
        String  state=request.getParameter("state");
        String  source=request.getParameter("source");

        String editTime=DateTimeUtil.getSysTime();
        String editBy=((User)request.getSession().getAttribute("user")).getName();

        String  description=request.getParameter("description");
        String  contactSummary=request.getParameter("contactSummary");
        String  nextContactTime=request.getParameter("nextContactTime");
        String  address=request.getParameter("address");

        Clue clue=new Clue();

        clue.setId(id);
        clue.setFullname(fullname);
        clue.setAppellation(appellation);
        clue.setOwner(owner);
        clue.setCompany(company);
        clue.setJob(job);
        clue.setEmail(email);
        clue.setPhone(phone);
        clue.setWebsite(website);
        clue.setMphone(mphone);
        clue.setState(state);
        clue.setSource(source);

        clue.setEditTime(editTime);
        clue.setEditBy(editBy);

        clue.setDescription(description);
        clue.setContactSummary(contactSummary);
        clue.setNextContactTime(nextContactTime);
        clue.setAddress(address);

        System.out.println(clue);

        ClueService cs= (ClueService) ServiceFactory.getService(new ClueServiceImpl());

        boolean flag=cs.update(clue);
        PrintJson.printJsonFlag(response,flag);


    }

    private void getUserListAndClue(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("进入到查询用户信息和根据线索id查询单条线索的操作");
        String id=request.getParameter("id");

        //userList可以使用之前写过的方法，所以这里只用通过id得到单条线索就够了
        UserService us= (UserService) ServiceFactory.getService(new UserServiceImpl());//!!!!!!!!!!!!!!!!特殊!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        List<User> uList=us.getUserList();

        ClueService as= (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        Clue c=as.getSingleClue(id);

        Map<String,Object> map=new HashMap<String, Object>();

        map.put("uList",uList);
        map.put("c",c);

        PrintJson.printJsonObj(response,map);
    }


//下面的方法是得到线索相关的活动的
    private void getAcitivityListByClueId(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到得到线索相关的活动操作");
        String id =request.getParameter("clueId");
        //因为是，要返回市场活动，所以使用ActivityService!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
        ActivityService as= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        List<Activity> aList=as.getAcitivityListByClueId(id);
        PrintJson.printJsonObj(response,aList);
    }

    //总结一下：使用超链接跳转到详细信息页面的思路。思路是很重要的
    /*
    在某些字上面加上超链接之后，然后就去web.xml注册路径。
    然后去controller中判断路径，然后调用新定义的大方法，然后在大方法里面写小方法和请求转发
    其中小方法是调用数据库得到你需要的值。
     */
    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("跳转到线索信息详细页");
        String id=request.getParameter("id");
        ClueService cs= (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        Clue c=cs.detail(id);

        request.setAttribute("c",c);

        request.getRequestDispatcher("/workbench/clue/detail.jsp").forward(request,response);

    }

    private void pageList(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到查询线索列表的操作（结合条件查询+分页）");
        String  pageNoStr  = request.getParameter("pageNo");
        String  pageSizeStr  = request.getParameter("pageSize");
        String  fullname  = request.getParameter("fullname");
        String  company  = request.getParameter("company");
        String phone   = request.getParameter("phone");
        String  source  = request.getParameter("source");
        String   owner = request.getParameter("owner");
        String  mphone  = request.getParameter("mphone");
        String state   = request.getParameter("state");

        int pageNo=Integer.valueOf(pageNoStr);
        int pageSize=Integer.valueOf(pageSizeStr);
        int skipCount=(pageNo-1)*pageSize;

        Map<String,Object> map=new HashMap<String, Object>();

        map.put("skipCount",skipCount);
        map.put("pageSize",pageSize);//这里也是一个整数。

        map.put("fullname",fullname);
        map.put("company",company);
        map.put("phone",phone);
        map.put("source",source);
        map.put("owner",owner);
        map.put("mphone",mphone);
        map.put("state",state);

        ClueService cs= (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        PaginationVO<Clue> vo=cs.pageList(map);

        PrintJson.printJsonObj(response,vo);

    }

    private void save(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到线索保存操作");
    String id=UUIDUtil.getUUID();
    String  fullname=request.getParameter("fullname");
    String  appellation=request.getParameter("appellation");
    String  owner=request.getParameter("owner");
    String  company=request.getParameter("company");
    String  job=request.getParameter("job");
    String  email=request.getParameter("email");
    String  phone=request.getParameter("phone");
    String  website=request.getParameter("website");
    String  mphone=request.getParameter("mphone");
    String  state=request.getParameter("state");
    String  source=request.getParameter("source");
    String createTime=DateTimeUtil.getSysTime();
    String createBy=((User)request.getSession().getAttribute("user")).getName();
    String  description=request.getParameter("description");
    String  contactSummary=request.getParameter("contactSummary");
    String  nextContactTime=request.getParameter("nextContactTime");
    String  address=request.getParameter("address");

    Clue clue=new Clue();

    clue.setId(id);
    clue.setFullname(fullname);
    clue.setAppellation(appellation);
    clue.setOwner(owner);
    clue.setCompany(company);
    clue.setJob(job);
    clue.setEmail(email);
    clue.setPhone(phone);
    clue.setWebsite(website);
    clue.setMphone(mphone);
    clue.setState(state);
    clue.setSource(source);
    clue.setCreateTime(createTime);
    clue.setCreateBy(createBy);
    clue.setDescription(description);
    clue.setContactSummary(contactSummary);
    clue.setNextContactTime(nextContactTime);
    clue.setAddress(address);

        ClueService cs= (ClueService) ServiceFactory.getService(new ClueServiceImpl());

        boolean flag=cs.save(clue);
        PrintJson.printJsonFlag(response,flag);

    }

    private void getUserList(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("取得用户信息列表");
        UserService us= (UserService) ServiceFactory.getService(new UserServiceImpl());

        List<User> list=us.getUserList();//!!!!!!!!!!!!!!!!!!!特殊!!!!!!!!!!!!!!!!!!!!!!!!!

        PrintJson.printJsonObj(response,list);

    }
}
