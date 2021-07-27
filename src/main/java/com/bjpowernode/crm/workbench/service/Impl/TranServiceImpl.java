package com.bjpowernode.crm.workbench.service.Impl;

import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.SqlSessionUtil;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.vo.PaginationVO;
import com.bjpowernode.crm.workbench.dao.*;
import com.bjpowernode.crm.workbench.domain.*;
import com.bjpowernode.crm.workbench.service.TranService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TranServiceImpl  implements TranService {
    private TranDao tranDao= SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    private TranHistoryDao tranHistoryDao=SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);
    private ActivityDao activityDao=SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);
    private ContactsDao contactsDao=SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);
    private CustomerDao customerDao=SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    private TranRemarkDao tranRemarkDao=SqlSessionUtil.getSqlSession().getMapper(TranRemarkDao.class);

    @Override
    public List<Activity> getActivityByName(String aname) {
        List<Activity> aList=activityDao.getActivityByName(aname);

        return aList;
    }
    @Override
    public List<Contacts> getContactsByName(String cname) {
        List<Contacts> cList=contactsDao.getContactsByName(cname);
        return cList;
    }
    @Override
    public List<String> getCustomerName(String name) {
        List<String> sList=customerDao.getCustomerName(name);

        return sList;
    }
    @Override
    public boolean save(Tran t, String customerName) {
        boolean flag=true;

        Customer cus=customerDao.getCustomerByName(customerName);//这个方法再convert中使用过。不用重新再写~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        if(cus==null){
            cus=new Customer();
            //下面的set完全是可以不写太多，只写一些简单的即可。这些都视用户的需求而定。但是我们这里是尽可能的多填充一些信息

            cus.setId(UUIDUtil.getUUID());
            cus.setContactSummary(t.getContactSummary());
            cus.setCreateBy(t.getCreateBy());
            cus.setCreateTime(t.getCreateTime());//这里的时间就算是使用t的，前后跳转也不过是几毫秒。不会影响太大
            cus.setDescription(t.getDescription());
            cus.setOwner(t.getOwner());
            cus.setName(customerName);
            cus.setNextContactTime(t.getNextContactTime());


            int count1=customerDao.save(cus);//这的方法仍旧是使用convert中的。~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            if(count1!=1){
                flag=false;
            }
        }
        //到这一步说明customer一定是存在的。而且根据实际情况。世界上的公司名字也只能有一个，不会有重复的情况，所以这里不考虑customer即公司的
        //名字出现重复一致。
        t.setCustomerId(cus.getId());

        int count2=tranDao.save(t);
        if(count2!=1){
            flag=false;
        }

        //添加交易历史。
        TranHistory th=new TranHistory();
        th.setId(UUIDUtil.getUUID());
        th.setCreateTime(DateTimeUtil.getSysTime());
        th.setCreateBy(t.getCreateBy());
        th.setExpectedDate(t.getExpectedDate());
        th.setMoney(t.getMoney());
        th.setTranId(t.getId());
        th.setStage(t.getStage());

        int count3=tranHistoryDao.save(th);
        if(count3!=1){
            flag=false;
        }

        return flag;
    }
    @Override
    public PaginationVO<Tran> pageList(Map<String, Object> map) {
        int tatal=tranDao.getTotalByCondition(map);

        List<Tran> dataList =tranDao.getTranListByCondition(map);


        PaginationVO<Tran> vo = new PaginationVO<Tran>();

        vo.setTotal(tatal);
        vo.setDataList(dataList);
        return vo;



    }
    @Override
    public Tran getTranById(String id) {
        Tran tr=tranDao.getTranById(id);
        return tr;
    }
    @Override
    public List<TranHistory> getHistoryListById(String tranId) {
        List<TranHistory> hList=tranHistoryDao.getHistoryListById(tranId);
        return hList;
    }
    @Override
    public boolean changeStage(Tran tr) {
        boolean flag=true;
        int count1= tranDao.changeStage(tr);
        if(count1!=1){
            flag=false;
        }

        TranHistory th=new TranHistory();
        th.setId(UUIDUtil.getUUID());
        th.setCreateBy(tr.getEditBy());//注意这里是传入的交易修改人
        th.setCreateTime(DateTimeUtil.getSysTime());
        th.setExpectedDate(tr.getExpectedDate());
        th.setMoney(tr.getMoney());
        th.setTranId(tr.getId());
        th.setStage(tr.getStage());

        int count2=tranHistoryDao.save(th);
        if(count2!=1){
            flag=false;
        }

        return flag;
    }
    @Override
    public Map<String, Object> getCharts() {
        int total=tranDao.getTotal();

        List<Map<String,Object>> dataList=tranDao.getCharts();

        Map<String ,Object> map=new HashMap<>();
        map.put("total",total);
        map.put("dataList",dataList);

        return map;
    }
    @Override
    public boolean update(Tran t, String customerName) {
        boolean flag=true;

        Customer cus=customerDao.getCustomerByName(customerName);//这个方法再convert中使用过。不用重新再写~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        if(cus==null){
            cus=new Customer();
            //下面的set完全是可以不写太多，只写一些简单的即可。这些都视用户的需求而定。但是我们这里是尽可能的多填充一些信息

            cus.setId(UUIDUtil.getUUID());
            cus.setContactSummary(t.getContactSummary());
            cus.setCreateBy(t.getEditBy());
            cus.setCreateTime(t.getEditTime());//这里的时间就算是使用t的，前后跳转也不过是几毫秒。不会影响太大
            cus.setDescription(t.getDescription());
            cus.setOwner(t.getOwner());
            cus.setName(customerName);
            cus.setNextContactTime(t.getNextContactTime());


            int count1=customerDao.save(cus);//这的方法仍旧是使用convert中的。~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            if(count1!=1){
                flag=false;
            }
        }
        //到这一步说明customer一定是存在的。而且根据实际情况。世界上的公司名字也只能有一个，不会有重复的情况，所以这里不考虑customer即公司的
        //名字出现重复一致。
        t.setCustomerId(cus.getId());

        int count2=tranDao.update(t);
        if(count2!=1){
            flag=false;
        }

        //添加交易历史。
        TranHistory th=new TranHistory();
        th.setId(UUIDUtil.getUUID());
        th.setCreateTime(DateTimeUtil.getSysTime());
        th.setCreateBy(t.getEditBy());
        th.setExpectedDate(t.getExpectedDate());
        th.setMoney(t.getMoney());
        th.setTranId(t.getId());
        th.setStage(t.getStage());

        int count3=tranHistoryDao.save(th);
        if(count3!=1){
            flag=false;
        }






        return flag;
    }
    @Override
    public Tran getSingleTranById(String id) {

        Tran tran=tranDao.getSingleTranById(id);
        return tran ;
    }
    @Override
    public boolean delete(String[] ids) {
        boolean flag=true;
        //交易历史需要删除吗？同理，删不删除都行。不删除其他人也看不到，但是占用数据库内存。变成了垃圾信息。
        //先删除对应的交易历史.
        //后来我又觉得，交易历史不能删除。
//        int count1=tranHistoryDao.getTotalById(ids);
//        int count2=tranHistoryDao.delete(ids);
//        if(count1!=count2){
//            flag=false;
//        }

        //删除交易备注。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。
        int count5=tranRemarkDao.getTotalByIds(ids);
        int count6=tranRemarkDao.deleteByIds(ids);
        if(count5 !=count6){
            flag=false;
        }

        //删除交易
        int count3=tranDao.getTotalById(ids);//这里可以使用ids.size得到。这样就不用写这个sql语句了
        int count4=tranDao.delete(ids);
        if(count3!=count4){
            flag=false;
        }

        //交易都删除了，交易历史也就不用再添加了
        //因为你就算添加了交易历史。其他人再也找不到这个交易对应的历史，因为交易已经被删除了
        //如果你删除交易后，添加了交易历史，除非管理员知道被删除交易的id，然后去数据库中查看。，才能查看到其对应的交易历史
        //所以说这里没必要添加其对应的交易历史






        return flag;
    }

    @Override
    public boolean saveRemark(TranRemark trr) {
        boolean flag=true;
        int count=tranRemarkDao.saveRemark(trr);
        if(count!=1){
            flag=false;
        }

        return flag;
    }

    @Override
    public List<TranRemark> getRemarkListByTid(String transactionId) {
        List<TranRemark> trrList = tranRemarkDao.getRemarkListByTid(transactionId);
        return trrList;

    }

    @Override
    public boolean updateRemark(TranRemark trr) {
        int count = tranRemarkDao.updateRemark(trr);//这里因为使用dao接口调用了方法，所以要在到中定义方法
        boolean flag = true;
        if (count != 1) {
            flag = false;
        }


        return flag;
    }

    @Override
    public boolean deleteRemark(String id) {
        boolean flag = true;
        int count = tranRemarkDao.deleteById(id);  //sql语句中只用写一句就行了。不用管owner，因为owner'在前端
                                                    //会有别的处理方法
        if (count != 1) {
            flag = false;
        }
        return flag;
    }

}
