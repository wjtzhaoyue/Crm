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
import com.bjpowernode.crm.workbench.service.ContactsService;

import com.bjpowernode.crm.workbench.service.Impl.ContactsServiceImpl;
import com.bjpowernode.crm.workbench.service.Impl.TranServiceImpl;
import com.bjpowernode.crm.workbench.service.TranService;


import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ContactsController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到联系人控制器");

        String path = request.getServletPath();

        if ("/workbench/contacts/pageList.do".equals(path)) {
            pageList(request,response);
        } else if ("/workbench/contacts/getUserList.do".equals(path)) {
            getUserList(request,response);
        } else if ("/workbench/contacts/save.do".equals(path)) {
           save(request,response);
        }else if ("/workbench/contacts/getUserListAndContacts.do".equals(path)) {
            getUserListAndContacts(request,response);
        }else if ("/workbench/contacts/update.do".equals(path)) {
            update(request,response);
        }else if ("/workbench/contacts/delete.do".equals(path)) {
            delete(request,response);
        }else if ("/workbench/contacts/detail.do".equals(path)) {
            detail(request,response);
        }else if ("/workbench/contacts/getRemarkListByCid.do".equals(path)) {
            getRemarkListByCid(request,response);
        }else if ("/workbench/contacts/saveRemark.do".equals(path)) {
            saveRemark(request,response);
        }else if ("/workbench/contacts/updateRemark.do".equals(path)) {
            updateRemark(request,response);
        }else if ("/workbench/contacts/deleteRemark.do".equals(path)) {
            deleteRemark(request,response);
        }else if ("/workbench/contacts/getTranListByCid.do".equals(path)) {
            getTranListByCid(request,response);
        }else if ("/workbench/contacts/deleteTran.do".equals(path)) {
            deleteTran(request,response);
        }else if ("/workbench/contacts/getActivityListByCid.do".equals(path)) {
            getActivityListByCid(request,response);
        }else if ("/workbench/contacts/Unbind.do".equals(path)) {
            Unbind(request,response);
        }else if ("/workbench/contacts/getActivityByName.do".equals(path)) {
            getActivityByName(request,response);
        }else if ("/workbench/contacts/guanlian.do".equals(path)) {
            guanlian(request,response);
        }

    }

    private void guanlian(HttpServletRequest request, HttpServletResponse response) {
        String ids[]=request.getParameterValues("id");
        String cid=request.getParameter("cid");
        ContactsService cs= (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        List<Activity> aList=cs.getActivityListByAids(ids);

        ContactsService cs1= (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        boolean flag=cs1.saveClueActivityRelation(aList,cid);

        Map<String ,Object> map=new HashMap<>();
        map.put("success",flag);
        map.put("aList",aList);
        PrintJson.printJsonObj(response,map);

    }

    private void getActivityByName(HttpServletRequest request, HttpServletResponse response) {
        String aname=request.getParameter("aname");
        TranService ts= (TranService) ServiceFactory.getService(new TranServiceImpl());
        List<Activity> aList=ts.getActivityByName(aname);
        PrintJson.printJsonObj(response,aList);
    }

    private void Unbind(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到解除联系人与活动之间关系的操作");
        String id=request.getParameter("id");
        ContactsService cs= (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        boolean flag=cs.Unbind(id);
        PrintJson.printJsonFlag(response,flag);
    }

    private void getActivityListByCid(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到根据联系人id查询市场活动的操作");
        String id=request.getParameter("id");
        ContactsService cs= (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        List<Activity>  aList=cs.getActivityListByCid(id);
        PrintJson.printJsonObj(response,aList);

    }

    private void deleteTran(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到交易的删除操作");
        String id= request.getParameter("id");
        String ids[]={id};
        TranService ts= (TranService) ServiceFactory.getService(new TranServiceImpl());
        boolean flag=ts.delete(ids);
        PrintJson.printJsonFlag(response,flag);
    }

    private void getTranListByCid(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到展现与该联系人相关的所有交易列表");
        String id=request.getParameter("id");
        ContactsService cs= (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        List<Tran> tList=cs.getTranListByCid(id);
        PrintJson.printJsonObj(response,tList);
    }

    private void deleteRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("删除备注的操作");
        String id=request.getParameter("id");

        ContactsService cs= (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        boolean flag=cs.deleteRemark(id);
        PrintJson.printJsonFlag(response,flag);
    }

    private void updateRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("执行修改备注的操作");


        String id= request.getParameter("id");
        String noteContent=request.getParameter("noteContent");

        String editTime=DateTimeUtil.getSysTime();
        String editBy=((User)request.getSession().getAttribute("user")).getName();

        String editFlag="1";

        ContactsRemark cr=new ContactsRemark();

        cr.setId(id);//这里之所以设置id是为了将ar传回后端数据库，根据id进行修改操作
        cr.setNoteContent(noteContent);
        cr.setEditTime(editTime);
        cr.setEditBy(editBy);
        cr.setEditFlag(editFlag);

        ContactsService cs= (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        boolean flag=cs.updateRemark(cr); //这里使用动态代理，所以接着要去Service接口中写方法


        Map<String,Object> map=new HashMap<String, Object>();
        map.put("cr",cr);
        map.put("success",flag);

        PrintJson.printJsonObj(response,map);
    }

    private void saveRemark(HttpServletRequest request, HttpServletResponse response) {
        String noteContent = request.getParameter("noteContent");
        String contactsId = request.getParameter("contactsId");
        String createTime=DateTimeUtil.getSysTime();
        String createBy=((User)request.getSession().getAttribute("user")).getName();
        String id = UUIDUtil.getUUID();
        String editFlag="0";

        ContactsRemark cr=new ContactsRemark();

        cr.setContactsId(contactsId);
        cr.setNoteContent(noteContent);
        cr.setCreateTime(createTime);
        cr.setCreateBy(createBy);
        cr.setEditFlag(editFlag);
        cr.setId(id);

        ContactsService cs= (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());

        boolean flag=cs.saveRemark(cr);//这里使用动态代理，所以接着要去Service接口中写方法
        Map<String,Object> map=new HashMap<String, Object>();
        map.put("cr",cr);
        map.put("success",flag);

        PrintJson.printJsonObj(response,map);
    }

    private void getRemarkListByCid(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("根据联系人id，取得备注信息列表");
        String contactsId=request.getParameter("contactsId");

        ContactsService cs= (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        List<ContactsRemark> crList =cs.getRemarkListByAid(contactsId);
        PrintJson.printJsonObj(response,crList);
    }

    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("跳转到联系人详细信息页面");
        String  id =request.getParameter("id");

        ContactsService cs= (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());

        Contacts c=cs.detail(id);


        request.setAttribute("c",c);

        request.getRequestDispatcher("/workbench/contacts/detail.jsp").forward(request,response);

    }

    private void delete(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("执行联系人的删除操作");

        String ids[] =request.getParameterValues("id");//这里的id是地址栏中传过来的id！！！！！!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!！！！！！！！！！！！

        ContactsService cs= (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());

        boolean flag=cs.delete(ids);

        PrintJson.printJsonFlag(response,flag);

    }

    private void update(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("执行联系人修改操作");

        String id=request.getParameter("id");
        String owner = request.getParameter("owner");
        String  source = request.getParameter("source");
        String fullname = request.getParameter("fullname");
        String appellation = request.getParameter("appellation");
        String  job= request.getParameter("job");
        String  mphone= request.getParameter("mphone");
        String email = request.getParameter("email");
        String  birth = request.getParameter("birth");
        String customerName = request.getParameter("customerName");
        String description = request.getParameter("description");
        String  contactSummary= request.getParameter("contactSummary");
        String  nextContactTime= request.getParameter("nextContactTime");
        String  address= request.getParameter("address");

        String editTime= DateTimeUtil.getSysTime();
        String editBy=((User)request.getSession().getAttribute("user")).getName();

        Contacts contacts=new Contacts();
        contacts.setId(id);
        contacts.setOwner(owner);
        contacts.setSource(source);
        contacts.setFullname(fullname);
        contacts.setAppellation(appellation);
        contacts.setJob(job);
        contacts.setMphone(mphone);
        contacts.setEmail(email);
        contacts.setBirth(birth);
        //contacts.setCustomerId();
        contacts.setDescription(description);
        contacts.setContactSummary(contactSummary);
        contacts.setNextContactTime(nextContactTime);
        contacts.setAddress(address);

        contacts.setEditTime(editTime);
        contacts.setEditBy(editBy);

        ContactsService cs= (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());

        boolean flag=cs.update(contacts,customerName);
        PrintJson.printJsonFlag(response,flag);

    }

    private void getUserListAndContacts(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到查询用户信息和根据联系人id查询单条记录的操作");

        String id=request.getParameter("id");
        //这里使用的还是Activity代理。正在这个代理的方法里面再使用接口中的方法
        ContactsService cs= (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());

        Map<String,Object> map=cs.getUserListAndContacts(id);
        PrintJson.printJsonObj(response,map);
    }


    private void save(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("执行联系人添加操作");

        String id= UUIDUtil.getUUID();
        String owner = request.getParameter("owner");
        String  source = request.getParameter("source");
        String fullname = request.getParameter("fullname");
        String appellation = request.getParameter("appellation");
        String  job= request.getParameter("job");
        String  mphone= request.getParameter("mphone");
        String email = request.getParameter("email");
        String  birth = request.getParameter("birth");

        String customerName = request.getParameter("customerName");

        String description = request.getParameter("description");
        String  contactSummary= request.getParameter("contactSummary");
        String  nextContactTime= request.getParameter("nextContactTime");
        String  address= request.getParameter("address");

        String creatTime= DateTimeUtil.getSysTime();
        String creatBy=((User)request.getSession().getAttribute("user")).getName();

       Contacts contacts=new Contacts();
        contacts.setId(id);
        contacts.setOwner(owner);
        contacts.setSource(source);
        contacts.setFullname(fullname);
        contacts.setAppellation(appellation);
        contacts.setJob(job);
        contacts.setMphone(mphone);
        contacts.setEmail(email);
        contacts.setBirth(birth);
        //contacts.setCustomerId();
        contacts.setDescription(description);
        contacts.setContactSummary(contactSummary);
        contacts.setNextContactTime(nextContactTime);
        contacts.setAddress(address);

        contacts.setCreateTime(creatTime);
        contacts.setCreateBy(creatBy);

        ContactsService cs= (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());

            boolean flag=cs.save(contacts,customerName);
            PrintJson.printJsonFlag(response,flag);
    }

    private void getUserList(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("获得用户信息列表");
        UserService us= (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> uList=us.getUserList();

        PrintJson.printJsonObj(response,uList);
    }

    private void pageList(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到查询联系人信息列表的操作（结合条件查询+分页）");

        String  pageNoStr =request.getParameter("pageNo");
        String  pageSizeStr =request.getParameter("pageSize");

        String  owner=request.getParameter("owner");
        String  fullname=request.getParameter("fullname");
        String  customerId =request.getParameter("customerId");
        String  source =request.getParameter("source");
        String  birth =request.getParameter("birth");

        //计算按页展示时候 跳过的条数

        int pageNo=Integer.valueOf(pageNoStr);
        int pageSize=Integer.valueOf(pageSizeStr);
        int skipCount=(pageNo-1)*pageSize;

        Map<String,Object> map=new HashMap<String, Object>();
        map.put("skipCount",skipCount);//这里是为sql语句中的limit 分页 做准备。即 这里是一个整数，将前端传送过来的当前页码。转化为要滤过的数目
        map.put("pageSize",pageSize);//这里也是一个整数。

        map.put("fullname",fullname);
        map.put("owner",owner);
        map.put("customerId",customerId);
        map.put("source",source);
        map.put("birth",birth);

        ContactsService cs= (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());

        //因为前端的导航页面有很多菜单都会用到这个分页操作的返回值，所以考虑将其封装为一个新的组装的类。
        //类  有两个属性：1 是 total 。2 是 List集合
        //这里前端现需要的返回值是：1.查询到的总条数 和 2 . 活动的list集合
        // 所以这里使用vo 。注意：vo是从后端向前端传输数据的时候才考虑使用。
        //前端向后端传是使用map
        PaginationVO<Contacts> vo =cs.pageList(map);
        PrintJson.printJsonObj(response,vo);
    }
}
