package com.bjpowernode.crm.workbench.service.Impl;

import com.bjpowernode.crm.exception.AddActivityException;
import com.bjpowernode.crm.settings.dao.UserDao;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.SqlSessionUtil;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.vo.PaginationVO;
import com.bjpowernode.crm.workbench.dao.ContactsDao;
import com.bjpowernode.crm.workbench.dao.CustomerDao;
import com.bjpowernode.crm.workbench.dao.CustomerRemarkDao;
import com.bjpowernode.crm.workbench.dao.TranDao;
import com.bjpowernode.crm.workbench.domain.*;
import com.bjpowernode.crm.workbench.service.CustomerService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CustomerServiceImpl implements CustomerService {

    private CustomerDao customerDao= SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    private UserDao userDao=SqlSessionUtil.getSqlSession().getMapper(UserDao.class);
    private CustomerRemarkDao customerRemarkDao=SqlSessionUtil.getSqlSession().getMapper(CustomerRemarkDao.class);
    private TranDao tranDao=SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    private ContactsDao contactsDao=SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);

    public PaginationVO<Customer> pageList(Map<String, Object> map) {

        int total = customerDao.getTotalByCondition(map);

        //取得活动列表
        List<Customer> dataList = customerDao.getCustomerListByCondition(map);


        //将上面的两者封装到vo ，作为返回值返回去

        PaginationVO<Customer> vo = new PaginationVO<Customer>();
        vo.setTotal(total);
        vo.setDataList(dataList);
        return vo;
    }

    @Override
    public boolean save(Customer customer) {
        boolean flag = true;
        int count = customerDao.save(customer);
        if (count != 1) {
            flag = false;
        }
        return flag;
    }

    @Override
    public Map<String, Object> getUserListAndCustomer(String id) {
        List<User> uList = userDao.getUserList();

        Customer c = customerDao.getCustomerById(id);

        Map<String, Object> map = new HashMap<String, Object>();
        map.put("uList", uList);
        map.put("c", c);

        return map;
    }

    @Override
    public boolean update(Customer customer) {
        boolean flag = true;
        int count = customerDao.update(customer);

        if (count != 1) {
            flag = false;
        }

        return flag;
    }

    @Override
    public Customer getCustomerById(String id) {
        Customer c = customerDao.getDetailCustomerByIdDetail(id);
        return c;
    }

    @Override
    public List<CustomerRemark> getRemarkListByCid(String customerId) {
        List<CustomerRemark> crList = customerRemarkDao.getRemarkListByCid(customerId);

        return crList;
    }

    @Override
    public boolean saveRemark(CustomerRemark cr) {

        int count = customerRemarkDao.saveRemark(cr);//这里因为使用dao接口调用了方法，所以要在到中定义方法

        boolean flag = true;
        if (count != 1) {
            flag = false;
        }


        return flag;
    }

    @Override
    public boolean updateRemark(CustomerRemark cr) {
        int count = customerRemarkDao.updateRemark(cr);//这里因为使用dao接口调用了方法，所以要在到中定义方法
        boolean flag = true;
        if (count != 1) {
            flag = false;
        }


        return flag;
    }

    @Override
    public boolean deleteRemark(String id) {
        boolean flag = true;
        int count = customerRemarkDao.deleteRemarkById(id);

        if (count != 1) {
            flag = false;
        }
        return flag;
    }

    @Override
    public List<Tran> getTranListByCid(String id) {
        List<Tran> tList = tranDao.getTranListByCusid(id);

        return tList;
    }

    @Override
    public List<Contacts> getContactsListByCid(String id) {
        List<Contacts> conList=contactsDao.getContactsListByCid(id);
        return conList;
    }

    @Override
    public boolean deleteContacts(String id) {
        boolean flag=true;
        int count=contactsDao.deleteContacts(id);
        if(count!=1){
            flag=false;
        }
        return flag;
    }

    @Override
    public boolean saveContactsAndPanDuan(Contacts contacts, String customerName) {
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
    public boolean delete(String[] ids) {
        boolean flag = true;
        //删除备注。
        int count1=customerRemarkDao.getCountByCids(ids);
        int count2=customerRemarkDao.deleteByCids(ids);
        if(count1!=count2){
            flag=false;
        }
        //删除联系人表中的与客户（即公司）对应的联系人。
        int count3=contactsDao.getCountByCids(ids);
        int count4=contactsDao.deleteByCids(ids);
        if(count3!=count4){
            flag=false;
        }
        //删除与该客户（即公司）的交易..这里不能使用tran的批量删除方法。因为tran'的批量删除操作传入的
        //ids是交易的id。而这里传入的参数ids'是customer的ids
        int count5=tranDao.getTotalByCustomerIds(ids);
        int count6=tranDao.deleteByCustomerIds(ids);
        if(count5!=count6){
            flag=false;
        }

        //删除客户
        int count7=customerDao.getCountByIds(ids);//这里没有必要去查询有多少条。只管删除就好了
        int count8=customerDao.delete(ids);
        if(count7!=count8){
            flag=false;
        }

        return flag;
    }

}
