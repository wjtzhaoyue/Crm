package com.bjpowernode.crm.workbench.service.Impl;

import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.SqlSessionUtil;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.vo.PaginationVO;
import com.bjpowernode.crm.workbench.dao.*;
import com.bjpowernode.crm.workbench.domain.*;
import com.bjpowernode.crm.workbench.service.ClueService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

//小总结：
/*
 开始一个模块的建设的时候。要先写之前的基础框架，比如实体类创建，dao ，dao.xml

 之后开始，先写service接口 然后实现service接口实现类。其中的关系如下：
    因为controller中要使用动态代理机制，生成service的代理对象，并且调用service接口中的方法
    所以，要在service接口中写上方法，那么service接口的实现类就要 实现该方法。
    而在service实现类中， service实现类要通过 成员属性 去调用 dao 接口中的方法
    dao接口要定义方法，并且dao.xml要使用sql语句实现他。
 */

public class ClueServiceImpl implements ClueService {
    //private ClueDao clueDao
    private ClueDao clueDao = SqlSessionUtil.getSqlSession().getMapper(ClueDao.class);//虽然是接口，但其仍能作为成员属性，只不过是不能new对象而已
    private ClueRemarkDao clueRemarkDao= SqlSessionUtil.getSqlSession().getMapper(ClueRemarkDao.class);
    private ClueActivityRelationDao clueActivityRelationDao=SqlSessionUtil.getSqlSession().getMapper(ClueActivityRelationDao.class);

    private  ActivityDao activityDao=SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);

    private TranDao tranDao=SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    private TranHistoryDao tranHistoryDao=SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);

    private CustomerDao customerDao=SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    private CustomerRemarkDao customerRemarkDao=SqlSessionUtil.getSqlSession().getMapper(CustomerRemarkDao.class);

    private ContactsDao contactsDao=SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);
    private  ContactsRemarkDao contactsRemarkDao=SqlSessionUtil.getSqlSession().getMapper(ContactsRemarkDao.class);
    private  ContactsActivityRelationDao contactsActivityRelationDao =SqlSessionUtil.getSqlSession().getMapper(ContactsActivityRelationDao.class);

   public boolean save(Clue clue) {
        boolean flag = true;

        int count = clueDao.save(clue);
        if (count != 1) {
            flag = false;
        }
        return flag;
    }

    //总是忘记传参数！1！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
    public Clue detail(String id) {
        Clue c=clueDao.detail(id);
        return c;
    }

    public PaginationVO<Clue> pageList(Map<String, Object> map) {

        int tatal = clueDao.getTotalByCondition(map);

        List<Clue> dataList = clueDao.getClueListByCondition(map);

        PaginationVO<Clue> vo=new PaginationVO<Clue>();

        vo.setTotal(tatal);
        vo.setDataList(dataList);


        return vo;
    }

    public Clue getSingleClue(String id) {
        /*这里虽然会让人想到使用当前java文件中的detail方法，但是仔细过去一看这个detail方法，发现其掺入参数id
        的方式不合适，所以只能自己在写一遍。虽然他和detail方法几乎一样，
        但是这里得到的线索我们不需要他的owner转化为中文。我们这一步可以在前端通过比较得到的id得到owner的中文
         */

       Clue clue=clueDao.getSingleClue(id);
       return clue;
    }

    public boolean update(Clue clue) {

        int count=clueDao.update(clue);
        boolean flag=true;
        if(count!=1){
            flag=false;
        }
        return flag;
    }

    public List<ClueRemark> getRemarkListByCid(String clueId) {
        List<ClueRemark> cr=clueRemarkDao.getRemarkListByCid(clueId);

        return cr;
    }

    public boolean updateRemark(ClueRemark cr) {
        int count = clueRemarkDao.updateRemark(cr);

        boolean flag = true;
        if (count != 1) {
            flag = false;
        }
        return flag;

    }

    public boolean deleteRemark(String id) {
        boolean flag = true;
        int count = clueRemarkDao.deleteById(id);

        if (count != 1) {
            flag = false;
        }
        return flag;
    }

    public boolean saveRemark(ClueRemark cr) {
        int count = clueRemarkDao.saveRemark(cr);//这里因为使用dao接口调用了方法，所以要在到中定义方法

        boolean flag = true;
        if (count != 1) {
            flag = false;
        }
        return flag;
    }

    public boolean unbind(String id) {
        int count=clueActivityRelationDao.unbind(id);
        boolean flag=true;
        if(count!=1){
            flag=false;
        }

        return flag;
    }

    public List<Activity> getActivityByNameAndNotByClueId(Map<String, String> map) {
        List<Activity> list=activityDao.getActivityByNameAndNotByClueId(map);

        return list;
    }

    public boolean guanlian(String cid, String[] aids) {
       boolean flag=true;
        ClueActivityRelation car=new ClueActivityRelation();
        int count;
       for(int i=0;i<aids.length;i++){//这里的for循环也可以使用类型的for循环
          // ClueActivityRelation car=new ClueActivityRelation();
           String id=UUIDUtil.getUUID();
           car.setId(id);
           car.setActivityId(aids[i]);
           car.setClueId(cid);
           count=clueActivityRelationDao.guanlian(car);
           if(count!=1){
               flag=false;
           }

       }

        return flag;
    }

    public List<Activity> getActivityByName(String aname) {
       List<Activity> aList=activityDao.getActivityByName(aname);

        return aList;
    }

    @Override
    public boolean convert(String clueId, Tran t, String createBy) {//想明白为什么是传入这三个参数！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！!!!!!!!!!!!!!
       boolean flag=true;
       String createTime= DateTimeUtil.getSysTime();

       Clue c=clueDao.getById(clueId);//这里已经得到了线索！！！

        String company=c.getCompany();//公司是客户(custom)
       Customer cus=customerDao.getCustomerByName(company);//注意这里是返回一个客户。并不是返回一个count。！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
        if(cus==null){
            cus=new Customer();
            cus.setId(UUIDUtil.getUUID());
            cus.setAddress(c.getAddress());
            cus.setWebsite(c.getWebsite());
            cus.setPhone(c.getPhone());
            cus.setOwner(c.getOwner());
            cus.setNextContactTime(c.getNextContactTime());
            cus.setName(company);
            cus.setDescription(c.getDescription());
            cus.setCreateTime(createTime);
            cus.setCreateBy(createBy);
            cus.setContactSummary(c.getContactSummary());

           int count1= customerDao.save(cus);
           if(count1!=1){
               flag=false;
           }

        }

        //创建联系人..联系人这里不用判断，因为一个公司可以有多个联系人。这里的联系人即即公司的老板。
        Contacts con =new Contacts();
        con.setId(UUIDUtil.getUUID());
        con.setAddress(c.getAddress());
        con.setAppellation(c.getAppellation());
        //con.setBirth();
        con.setContactSummary(c.getContactSummary());
        con.setCreateBy(createBy);
        con.setCreateTime(createTime);
        con.setCustomerId(cus.getId());
        con.setSource(c.getSource());
        con.setOwner(c.getOwner());
        con.setDescription(c.getDescription());
        con.setNextContactTime(c.getNextContactTime());
        con.setFullname(c.getFullname()); //老板
        con.setJob(c.getJob());
        con.setMphone(c.getMphone());
        con.setEmail(c.getEmail());

        int count2=contactsDao.save(con);
        if(count2!=1){
            flag=false;
        }

        //将线索的备注也分别转移到两张表中去

        //先查询备注
        List<ClueRemark> clueRemarkList=clueRemarkDao.getListByClueId(clueId);
        for(ClueRemark clueRemark :clueRemarkList) {
            String noteContent = clueRemark.getNoteContent();
            //创建客户备注对象
            CustomerRemark customerRemark = new CustomerRemark();
            customerRemark.setNoteContent(noteContent);
            customerRemark.setId(UUIDUtil.getUUID());
            customerRemark.setCustomerId(cus.getId());
            customerRemark.setCreateTime(createTime);
            customerRemark.setEditFlag("0");
            customerRemark.setCreateBy(createBy);

            int count3 = customerRemarkDao.save(customerRemark);
            if (count3 != 1) {
                flag = false;
            }

            ContactsRemark contactsRemark = new ContactsRemark();
            contactsRemark.setNoteContent(noteContent);
            contactsRemark.setId(UUIDUtil.getUUID());
            contactsRemark.setContactsId(con.getId());
            contactsRemark.setCreateTime(createTime);
            contactsRemark.setEditFlag("0");
            contactsRemark.setCreateBy(createBy);

            int count4 = contactsRemarkDao.save(contactsRemark);
            if (count4 != 1) {
                flag = false;
            }
        }
            //将线索与市场活动的关联关系 转移到 联系人与市场活动的关联关系
            List<ClueActivityRelation> clueActivityRelationList=clueActivityRelationDao.getListByClueId(clueId);
              for(ClueActivityRelation clueActivityRelation :clueActivityRelationList){
                  String activityId=clueActivityRelation.getActivityId();

                  ContactsActivityRelation contactsActivityRelation=new ContactsActivityRelation();
                  contactsActivityRelation.setActivityId(activityId);
                  contactsActivityRelation.setId(UUIDUtil.getUUID());
                  contactsActivityRelation.setContactsId(con.getId());

                  int count5=contactsActivityRelationDao.save(contactsActivityRelation);
                  if(count5!=1){
                      flag=false;
                  }
              }

              //如果上面传递过来交易的话，那么给交易加到数据库
            if(t!=null){
                //t里面已经有一些信息了。下面的这些信息是我们自己多写的，根据客户需求，去决定这里的要不要写
//                t.setId(id);
//                t.setMoney(money);
//                t.setName(name);
//                t.setExpectedDate(expectedDate);
//                t.setActivityId(activityId);
//                t.setStage(stage);
//                t.setCreateTime(createTime);
//                t.setCreateBy(createBy);

            t.setSource(c.getSource());
            t.setOwner(c.getOwner());
            t.setNextContactTime(c.getNextContactTime());
            t.setDescription(c.getDescription());
            t.setCustomerId(cus.getId());
            t.setContactsId(con.getId());
            t.setContactSummary(c.getContactSummary());

             int count6=tranDao.save(t);
                if(count6!=1){
                    flag=false;
                }

                //如果创建了交易，那么在交易历史里面添加一条数据
                TranHistory th=new TranHistory();
                th.setCreateBy(createBy);
                th.setTranId(t.getId());
                th.setStage(t.getStage());
                th.setMoney(t.getMoney());
                th.setExpectedDate(t.getExpectedDate());
                th.setCreateTime(createTime);
                th.setId(UUIDUtil.getUUID());

                int count7=tranHistoryDao.save(th);
                if(count7!=1){
                    flag=false;
                }

            }

            //删除备注。视频中的删除方法看着有点懵！！！！！为什么传入一个队就能删除id呢？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？

        for(ClueRemark clueRemark :clueRemarkList){
            int count8=clueRemarkDao.delete(clueRemark);

            if(count8!=1){
                flag=false;
            }
        }

        //删除市场活动和线索之间的关联关系
        for(ClueActivityRelation clueActivityRelation :clueActivityRelationList){
            int count9=clueActivityRelationDao.delete(clueActivityRelation);
            if(count9!=1){
                flag=false;
            }
        }
         //删除线索
        int count10=clueDao.delete(clueId);
        if(count10!=1){
            flag=false;
        }






        return flag;
    }
//这里是再index页面的线索删除操作。不会进行转化，而且支持批量删除操作。
    @Override
    public boolean delete(String[] ids) {
        //因为一条线索还对应着x条备注。所以要删除线索的时候，要先删除其有联系的备注
        boolean flag = true;

        //查询出需要删除的备注的数量
        int count1 = clueRemarkDao.getCountByCids(ids);
        //删除备注，返回受到影响的条数（即实际删除备注的数量）
        int count2 = clueRemarkDao.deleteByCids(ids);
        if (count1 != count2) {
            flag = false;
        }

        //删除线索对应的线索活动关系
        int count3 = clueActivityRelationDao.getCountByCids(ids);
        //删除备注，返回受到影响的条数（即实际删除备注的数量）
        int count4= clueActivityRelationDao.deleteByCids(ids);
        if (count3 != count4) {
            flag = false;
        }

        //删除市场活动
        int count5 = clueDao.deleteNoConvert(ids);
        if (count5 != ids.length) {
            flag = false;
        }

        return flag;

    }

    @Override
    public Map<String, Object> getCharts() {
        int total=clueDao.getTotal();

        List<Map<String,Object>> dataList=clueDao.getCharts();

        Map<String ,Object> map=new HashMap<>();
        map.put("total",total);
        map.put("dataList",dataList);

        return map;
    }


}
