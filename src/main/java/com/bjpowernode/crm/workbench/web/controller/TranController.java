package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.Impl.UserServiceImpl;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.utils.*;
import com.bjpowernode.crm.vo.PaginationVO;
import com.bjpowernode.crm.workbench.domain.*;
import com.bjpowernode.crm.workbench.service.Impl.TranServiceImpl;
import com.bjpowernode.crm.workbench.service.TranService;


import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TranController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        System.out.println("进入到交易控制器");

        String path = request.getServletPath();

        if("/workbench/transaction/add.do".equals(path)) {
            add(request, response);
        }else if ("/workbench/transaction/getActivityByName.do".equals(path)) {
            getActivityByName(request, response);
        }else if ("/workbench/transaction/getContactsByName.do".equals(path)) {
            getContactsByName(request, response);
        }else if ("/workbench/transaction/getCustomerName.do".equals(path)) {
            getCustomerName(request, response);
        }else if ("/workbench/transaction/save.do".equals(path)) {
            save(request, response);
        }else if ("/workbench/transaction/pageList.do".equals(path)) {
            pageList(request, response);
        }else if ("/workbench/transaction/detail.do".equals(path)) {
            detail(request, response);
        }else if ("/workbench/transaction/history.do".equals(path)) {
            history(request, response);
        }else if ("/workbench/transaction/changeStage.do".equals(path)) {
            changeStage(request, response);
        }else if ("/workbench/transaction/getChar.do".equals(path)) {
            getChar(request, response);
        }else if ("/workbench/transaction/edit.do".equals(path)) {
            edit(request, response);
        }else if ("/workbench/transaction/update.do".equals(path)) {
            update(request, response);
        }else if ("/workbench/transaction/delete.do".equals(path)) {
            delete(request, response);
        }else if ("/workbench/transaction/saveRemark.do".equals(path)) {
            saveRemark(request, response);
        }else if ("/workbench/transaction/getRemarkListByTid.do".equals(path)) {
            getRemarkListByTid(request, response);
        }else if ("/workbench/transaction/updateRemark.do".equals(path)) {
            updateRemark(request, response);
        }else if ("/workbench/transaction/deleteRemark.do".equals(path)) {
            deleteRemark(request, response);
        }

    }



    private void deleteRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("单个删除备注的操作");
        String id=request.getParameter("id");

        TranService ts= (TranService) ServiceFactory.getService(new TranServiceImpl());
        boolean flag=ts.deleteRemark(id);
        PrintJson.printJsonFlag(response,flag);
    }

    private void updateRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到交易的备注的更新操作");

        String id= request.getParameter("id");
        String noteContent=request.getParameter("noteContent");

        String editTime=DateTimeUtil.getSysTime();
        String editBy=((User)request.getSession().getAttribute("user")).getName();

        String editFlag="1";

        TranRemark trr=new TranRemark();

        trr.setId(id);//这里之所以设置id是为了将ar传回后端数据库，根据id进行修改操作
        trr.setNoteContent(noteContent);
        trr.setEditTime(editTime);
        trr.setEditBy(editBy);
        trr.setEditFlag(editFlag);

        TranService ts= (TranService) ServiceFactory.getService(new TranServiceImpl());
        boolean flag=ts.updateRemark(trr); //这里使用动态代理，所以接着要去Service接口中写方法


        Map<String,Object> map=new HashMap<String, Object>();
        map.put("trr",trr);
        map.put("success",flag);

        PrintJson.printJsonObj(response,map);




    }

    private void getRemarkListByTid(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到加载交易的备注的操作");
        String transactionId=request.getParameter("transactionId");

        TranService ts= (TranService) ServiceFactory.getService(new TranServiceImpl());
        List<TranRemark> trrList =ts.getRemarkListByTid(transactionId);
        PrintJson.printJsonObj(response,trrList);

    }

    private void saveRemark(HttpServletRequest request, HttpServletResponse response) {
        String noteContent = request.getParameter("noteContent");
        String transactionId = request.getParameter("transactionId");
        String createTime=DateTimeUtil.getSysTime();
        String createBy=((User)request.getSession().getAttribute("user")).getName();
        String id = UUIDUtil.getUUID();
        String editFlag="0";

        TranRemark trr=new TranRemark();

        trr.setTranId(transactionId);
        trr.setNoteContent(noteContent);
        trr.setCreateTime(createTime);
        trr.setCreateBy(createBy);
        trr.setEditFlag(editFlag);
        trr.setId(id);

        TranService ts= (TranService) ServiceFactory.getService(new TranServiceImpl());

        boolean flag=ts.saveRemark(trr);//这里使用动态代理，所以接着要去Service接口中写方法
        Map<String,Object> map=new HashMap<String, Object>();
        map.put("trr",trr);
        map.put("success",flag);

        PrintJson.printJsonObj(response,map);
    }

    private void delete(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到交易删除的操作(支持批量删除)");
        String ids[]=request.getParameterValues("id");
        TranService ts= (TranService) ServiceFactory.getService(new TranServiceImpl());
        boolean flag=ts.delete(ids);
        PrintJson.printJsonFlag(response,flag);

    }

    private void update(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到交易更新操作");
        String id=request.getParameter("id");
        //System.out.println(id+"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        String owner=request.getParameter("owner");
        String money=request.getParameter("money");
        String name=request.getParameter("name");
        String expectedDate=request.getParameter("expectedDate");
        String customerName=request.getParameter("customerName");//这个很特殊！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！1
        String stage=request.getParameter("stage");
        String type=request.getParameter("type");
        String source=request.getParameter("source");

        String activityId=request.getParameter("activityId");
        String contactsId =request.getParameter("contactsId");

        String editTime= DateTimeUtil.getSysTime();
        String editBy=((User)request.getSession().getAttribute("user")).getName();

        String description=request.getParameter("description");
        String contactSummary=request.getParameter("contactSummary");
        String nextContactTime=request.getParameter("nextContactTime");

        Tran t =new Tran();

        t.setId(id);
        t.setOwner(owner);
        t.setMoney(money);
        t.setName(name);
        t.setExpectedDate(expectedDate);
        t.setStage(stage);
        t.setType(type);
        t.setSource(source);
        t.setActivityId(activityId);
        t.setContactsId(contactsId);

        t.setEditTime(editTime);
        t.setEditBy(editBy);

        t.setDescription(description);
        //t.setCustomerId();这里这个需要特殊处理。去判断。我们并没有从前传过来这个id
        t.setContactSummary(contactSummary);
        t.setNextContactTime(nextContactTime);


        TranService ts= (TranService) ServiceFactory.getService(new TranServiceImpl());
        boolean flag=ts.update(t,customerName);//这里不用上传createBy，因为t一定存在。而之前的convert方法中，t是不确定是否为null

        PrintJson.printJsonFlag(response,flag);

       // if(flag){
            //这里只能使用重定向。因为若是使用请求转发，跳到index页面。但是地址栏仍旧是现在的save。do.然后你再刷新页面的
            //时候，它仍旧会进行save的操作，导致重复保存交易
           // response.sendRedirect(request.getContextPath()+"/workbench/transaction/index.jsp");
       // }


    }

    private void edit(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
        String id=request.getParameter("id");
       // System.out.println(id);
        //request.setAttribute("id",id);
        TranService tranService= (TranService)ServiceFactory.getService(new TranServiceImpl());
        Tran tr=tranService.getTranById(id);//这里的tr是被处理过的中文的交易！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！

        TranService tranService1= (TranService)ServiceFactory.getService(new TranServiceImpl());
        Tran tr1=tranService1.getSingleTranById(id);//只是为了简单得到没有处理过的，长串的activityId和contactsId

        ServletContext application=request.getServletContext();//得到application对象。
        Map<String ,String> pMap= (Map<String, String>) application.getAttribute("pMap");

        String possibility=pMap.get(tr.getStage());
        //此时可以去给Tran交易类添加一个属性。possibility。当然也可以直接将possibility通过setAttribute传到前端。！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
        tr.setPossibility(possibility);
        request.setAttribute("t",tr);
        request.setAttribute("t1",tr1);
        UserService userService= (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> uList=userService.getUserList();
        request.setAttribute("uList",uList);
        request.getRequestDispatcher("/workbench/transaction/edit.jsp").forward(request,response);
    }

    private void getChar(HttpServletRequest request, HttpServletResponse response) {
        TranService tranService= (TranService)ServiceFactory.getService(new TranServiceImpl());
         Map<String,Object> map=tranService.getCharts();
         PrintJson.printJsonObj(response,map);
    }

    private void changeStage(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("执行改变阶段的操作");
        String id =request.getParameter("id");
        String stage =request.getParameter("stage");
        String money= request.getParameter("money");
        String expectedDate= request.getParameter("expectedDate");

        String editTime=DateTimeUtil.getSysTime();
        String editBy=((User)request.getSession().getAttribute("user")).getName();

        Map<String,String> pMap= (Map<String, String>) request.getServletContext().getAttribute("pMap");

        TranService tranService= (TranService)ServiceFactory.getService(new TranServiceImpl());
        Tran tr=tranService.getTranById(id);
        //Tran tr=new Tran();
        //tr.setId(id);//这里能这样给已有的交易添加信息吗？！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
        tr.setEditBy(editBy);
        tr.setEditTime(editTime);
        tr.setStage(stage);
        tr.setPossibility(pMap.get(stage));

        TranService tranService1= (TranService)ServiceFactory.getService(new TranServiceImpl());
        boolean flag=tranService1.changeStage(tr);

        Map<String,Object> map=new HashMap<>();
        map.put("success",flag);
        map.put("tr",tr);
        PrintJson.printJsonObj(response,map);



    }

    private void history(HttpServletRequest request, HttpServletResponse response) {
        Map<String,String> pMap= (Map<String, String>) request.getServletContext().getAttribute("pMap");
        String tranId=request.getParameter("tranId");
        TranService tranService= (TranService)ServiceFactory.getService(new TranServiceImpl());
       List<TranHistory> hList= tranService.getHistoryListById(tranId);
       for(TranHistory history :hList){
           String possibility=pMap.get(history.getStage());
           history.setPossibility(possibility);//这里是给历史交易填的值！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！

       }
       PrintJson.printJsonObj(response,hList);
    }

    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id=request.getParameter("id");
        TranService ts= (TranService) ServiceFactory.getService(new TranServiceImpl());
        Tran tr=ts.getTranById(id);
        //在这里处理详细页面的可能性
        ServletContext application=request.getServletContext();//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        Map<String ,String> pMap= (Map<String, String>) application.getAttribute("pMap");
        String possibility=pMap.get(tr.getStage());
        //此时可以去给Tran交易类添加一个属性。possibility。当然也可以直接将possibility通过setAttribute传到前端。！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
        tr.setPossibility(possibility);

        request.setAttribute("tr",tr);
        request.getRequestDispatcher("/workbench/transaction/detail.jsp").forward(request,response);

    }

    private void pageList(HttpServletRequest request, HttpServletResponse response) {
        String pageNoStr =request.getParameter("pageNo");
        String pageSizeStr =request.getParameter("pageSize");

        int pageNo=Integer.valueOf(pageNoStr);
        int pageSize=Integer.valueOf(pageSizeStr);
        int skipCount=(pageNo-1)*pageSize;

        String owner =request.getParameter("owner");
        String name =request.getParameter("name");
        String customerId =request.getParameter("customerId");
        String stage  =request.getParameter("stage");
        String type =request.getParameter("type");
        String source =request.getParameter("source");
        String contactsId =request.getParameter("contactsId");

        // Tran t=new Tran(); //这里没有使用创建一个交易对象，然后作为参数传过去。原因是：传过来的参数有不是交易的的属性的customerId
        //customerId，这两个实际上传过来的参数为中文。所以我们使用map

        Map<String,Object > map=new HashMap<>();

        map.put("skipCount",skipCount);
        map.put("pageSize",pageSize);

        map.put("owner",owner);
        map.put("name",name);
        map.put("customerId",customerId);
        map.put("stage",stage);
        map.put("type",type);
        map.put("source",source);
        map.put("contactsId",contactsId);


        TranService ts= (TranService) ServiceFactory.getService(new TranServiceImpl());

        PaginationVO<Tran> vo =ts.pageList(map);

        PrintJson.printJsonObj(response,vo);


    }

    private void save(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到交易的添加操作");
        //从表单获得的数据，都是根据name属性得到value的值。文本框的value就是你输入的值！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
        //下拉列表的值也是 根据name属性得到value的值。只不过是name加载select上！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
        String id = UUIDUtil.getUUID();
        String owner=request.getParameter("owner");
        //System.out.println(owner+"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        //06f5fc056eac41558a964f96daa7f27c!!!!!得到的是form表单中下拉选项的value的值
        String money=request.getParameter("money");
        String name=request.getParameter("name");
        String expectedDate=request.getParameter("expectedDate");

        String customerName=request.getParameter("customerName");//这个很特殊！！要传走，看是否存在这个客户！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！1
                                                                    //而且我们前端传入的也是中文名字。但是我们后端需要的是id
                                                                    //所以我们这里需要处理
        String stage=request.getParameter("stage");
        String type=request.getParameter("type");
        //这里不用获取possibility，因为数据库中不要存这个数据。
        String source=request.getParameter("source");
        String activityId=request.getParameter("activityId");
        String contactsId =request.getParameter("contactsId");

        String createTime= DateTimeUtil.getSysTime();
        String createBy=((User)request.getSession().getAttribute("user")).getName();

        String description=request.getParameter("description");
        String contactSummary=request.getParameter("contactSummary");
        String nextContactTime=request.getParameter("nextContactTime");

        Tran t =new Tran();

        t.setId(id);
        t.setOwner(owner);
        t.setMoney(money);
        t.setName(name);
        t.setExpectedDate(expectedDate);
        t.setStage(stage);
        t.setType(type);
        t.setSource(source);
        t.setActivityId(activityId);
        t.setContactsId(contactsId);
        t.setCreateTime(createTime);
        t.setCreateBy(createBy);
        t.setDescription(description);
        //t.setCustomerId();这里这个需要特殊处理。去判断。我们并没有从前传过来这个id
        t.setContactSummary(contactSummary);
        t.setNextContactTime(nextContactTime);


        TranService ts= (TranService) ServiceFactory.getService(new TranServiceImpl());
        boolean flag=ts.save(t,customerName);//这里不用上传createBy，因为t一定存在。而之前的convert方法中，t是不确定是否为null

        if(flag){
            //这里只能使用重定向。因为若是使用请求转发，跳到index页面。但是地址栏仍旧是现在的save。do.然后你再刷新页面的
            //时候，它仍旧会进行save的操作，导致重复保存交易
            response.sendRedirect(request.getContextPath()+"/workbench/transaction/index.jsp");
            //response.sendRedirect(request.getContextPath()+"/workbench/customer/detail.jsp");
        }



    }

    private void getCustomerName(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("取得客户名称列表");
        String name =request.getParameter("name");
        TranService ts= (TranService) ServiceFactory.getService(new TranServiceImpl());
        List<String> sList=ts.getCustomerName(name);
        PrintJson.printJsonObj(response,sList);
    }

    private void getContactsByName(HttpServletRequest request, HttpServletResponse response) {
        String cname=request.getParameter("cname");
        TranService ts= (TranService) ServiceFactory.getService(new TranServiceImpl());
        List<Contacts> aList=ts.getContactsByName(cname);
        PrintJson.printJsonObj(response,aList);
    }

    private void getActivityByName(HttpServletRequest request, HttpServletResponse response) {
        String aname=request.getParameter("aname");
        TranService ts= (TranService) ServiceFactory.getService(new TranServiceImpl());
        List<Activity> aList=ts.getActivityByName(aname);
        PrintJson.printJsonObj(response,aList);

    }

    private void add(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到跳转到交易添加页面的操作");
        UserService userService= (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> uList=userService.getUserList();
        //这里是传统请求。使用域对象，将其传走！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
        request.setAttribute("uList",uList);
        request.getRequestDispatcher("/workbench/transaction/save.jsp").forward(request,response);
    }
}