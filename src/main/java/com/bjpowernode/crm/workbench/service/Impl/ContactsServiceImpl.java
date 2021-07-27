package com.bjpowernode.crm.workbench.service.Impl;

import com.bjpowernode.crm.settings.dao.UserDao;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.SqlSessionUtil;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.vo.PaginationVO;
import com.bjpowernode.crm.workbench.dao.*;
import com.bjpowernode.crm.workbench.domain.*;
import com.bjpowernode.crm.workbench.service.ContactsService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ContactsServiceImpl implements ContactsService {
    ContactsDao contactsDao= SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);
    CustomerDao customerDao=SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    UserDao userDao=SqlSessionUtil.getSqlSession().getMapper(UserDao.class);
    ContactsRemarkDao contactsRemarkDao=SqlSessionUtil.getSqlSession().getMapper(ContactsRemarkDao.class);
    ContactsActivityRelationDao contactsActivityRelationDao=SqlSessionUtil.getSqlSession().getMapper(ContactsActivityRelationDao.class);
    TranDao tranDao=SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    ActivityDao activityDao=SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);

    @Override
    public PaginationVO<Contacts> pageList(Map<String, Object> map) {
        //取得total
        int total = contactsDao.getTotalByCondition(map);

        //取得活动列表
        List<Contacts> dataList = contactsDao.getContactsListByCondition(map);


        //将上面的两者封装到vo ，作为返回值返回去

        PaginationVO<Contacts> vo = new PaginationVO<Contacts>();
        vo.setTotal(total);
        vo.setDataList(dataList);
        return vo;
    }

    @Override
    public boolean save(Contacts contacts, String customerName) {
        boolean flag=true;

        Customer cus=customerDao.getCustomerByName(customerName);//这个方法再convert中使用过。不用重新再写~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        if(cus==null){
            cus=new Customer();
            //下面的set完全是可以不写太多，只写一些简单的即可。这些都视用户的需求而定。但是我们这里是尽可能的多填充一些信息

            cus.setId(UUIDUtil.getUUID());
            cus.setContactSummary(contacts.getContactSummary());
            cus.setCreateBy(contacts.getCreateBy());
            cus.setCreateTime(contacts.getCreateTime());//这里的时间就算是使用t的，前后跳转也不过是几毫秒。不会影响太大
            cus.setDescription(contacts.getDescription());
            cus.setOwner(contacts.getOwner());
            cus.setName(customerName);
            cus.setNextContactTime(contacts.getNextContactTime());


            int count1=customerDao.save(cus);//这的方法仍旧是使用convert中的。~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            if(count1!=1){
                flag=false;
            }
        }
        //到这一步说明customer一定是存在的。而且根据实际情况。世界上的公司名字也只能有一个，不会有重复的情况，所以这里不考虑customer即公司的
        //名字出现重复一致。
        contacts.setCustomerId(cus.getId());

        int count2=contactsDao.save(contacts);
        if(count2!=1){
            flag=false;
        }

        return flag;

    }

    @Override
    public Map<String, Object> getUserListAndContacts(String id) {
        List<User> uList = userDao.getUserList();

       Contacts c = contactsDao.getById(id);

        Map<String, Object> map = new HashMap<String, Object>();
        map.put("uList", uList);
        map.put("c", c);

        return map;
    }

    @Override
    public boolean update(Contacts contacts, String customerName) {
        boolean flag=true;

        Customer cus=customerDao.getCustomerByName(customerName);//这个方法再convert中使用过。不用重新再写~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        if(cus==null){
            cus=new Customer();
            //下面的set完全是可以不写太多，只写一些简单的即可。这些都视用户的需求而定。但是我们这里是尽可能的多填充一些信息

            cus.setId(UUIDUtil.getUUID());
            cus.setContactSummary(contacts.getContactSummary());
            cus.setCreateBy(contacts.getCreateBy());
            cus.setCreateTime(contacts.getCreateTime());//这里的时间就算是使用t的，前后跳转也不过是几毫秒。不会影响太大
            cus.setDescription(contacts.getDescription());
            cus.setOwner(contacts.getOwner());
            cus.setName(customerName);
            cus.setNextContactTime(contacts.getNextContactTime());


            int count1=customerDao.save(cus);//这的方法仍旧是使用convert中的。~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

            if(count1!=1){
                flag=false;
            }
        }
        //到这一步说明customer一定是存在的。而且根据实际情况。世界上的公司名字也只能有一个，不会有重复的情况，所以这里不考虑customer即公司的
        //名字出现重复一致。
        contacts.setCustomerId(cus.getId());

        int count2=contactsDao.update(contacts);

        if(count2!=1){
            flag=false;
        }

        return flag;
    }

    @Override
    public boolean delete(String[] ids) {

        boolean flag = true;
        //查询出需要删除的备注的数量
        int count1 = contactsRemarkDao.getCountByCids(ids);


        //删除备注，返回受到影响的条数（即实际删除备注的数量）
        int count2 = contactsRemarkDao.deleteByCids(ids);

        if (count1 != count2) {
            flag = false;
        }

        //删除联系人活动关系表中的相关信息
        int count3 = contactsActivityRelationDao.getCountByCids(ids);
        //删除备注，返回受到影响的条数（即实际删除备注的数量）
        int count4= contactsActivityRelationDao.deleteByCids(ids);
        if (count3 != count4) {
            flag = false;
        }


        //删除市场活动
        int count5 = contactsDao.delete(ids);
        if (count5 != ids.length) {
            flag = false;
        }


        return flag;
    }

    @Override
    public Contacts detail(String id) {
        Contacts c = contactsDao.detail(id);


        return c;
    }

    @Override
    public List<ContactsRemark> getRemarkListByAid(String contactsId) {
        List<ContactsRemark> crList = contactsRemarkDao.getRemarkListByCid(contactsId);
        return crList;
    }

    @Override
    public boolean saveRemark(ContactsRemark cr) {
        int count = contactsRemarkDao.saveRemark(cr);//这里因为使用dao接口调用了方法，所以要在到中定义方法

        boolean flag = true;
        if (count != 1) {
            flag = false;
        }


        return flag;
    }

    @Override
    public boolean updateRemark(ContactsRemark cr) {
        int count = contactsRemarkDao.updateRemark(cr);//这里因为使用dao接口调用了方法，所以要在到中定义方法
        boolean flag = true;
        if (count != 1) {
            flag = false;
        }


        return flag;
    }

    @Override
    public boolean deleteRemark(String id) {
        boolean flag = true;
        int count = contactsRemarkDao.deleteById(id);

        if (count != 1) {
            flag = false;
        }
        return flag;
    }

    @Override
    public List<Tran> getTranListByCid(String id) {
        List<Tran> tList = tranDao.getTranListByConid(id);

        return tList;
    }

    @Override
    public List<Activity> getActivityListByCid(String id) {

        List<Activity> aList=activityDao.getActivityListByCid(id);
        return aList;
    }

    @Override
    public boolean Unbind(String id) {
        boolean flag=true;
        flag=contactsActivityRelationDao.Unbind(id);
        return flag;
    }

    @Override
    public List<Activity> getActivityListByAids(String[] ids) {
        List<Activity> aList=activityDao.getActivityListByAids(ids);
        return aList;
    }

    @Override
    public boolean saveClueActivityRelation(List<Activity> aList, String cid) {
        boolean flag=true;
        int count;
        for(Activity a :aList){
             count=0;
             ContactsActivityRelation car=new ContactsActivityRelation();
             car.setId(UUIDUtil.getUUID());
             car.setActivityId(a.getId());
             car.setContactsId(cid);
             count=contactsActivityRelationDao.save(car);
             if(count!=1){
                 flag=false;
             }
        }
        return flag;
    }


}
