package com.bjpowernode.crm.workbench.service.Impl;

import com.bjpowernode.crm.exception.AddActivityException;
import com.bjpowernode.crm.settings.dao.UserDao;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.utils.SqlSessionUtil;
import com.bjpowernode.crm.vo.PaginationVO;
import com.bjpowernode.crm.workbench.dao.ActivityDao;
import com.bjpowernode.crm.workbench.dao.ActivityRemarkDao;
import com.bjpowernode.crm.workbench.dao.ClueActivityRelationDao;
import com.bjpowernode.crm.workbench.dao.ContactsActivityRelationDao;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.ActivityRemark;
import com.bjpowernode.crm.workbench.domain.ContactsActivityRelation;
import com.bjpowernode.crm.workbench.service.ActivityService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActivityServiceImpl implements ActivityService {
    private ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);
    private ActivityRemarkDao activityremarkDao = SqlSessionUtil.getSqlSession().getMapper(ActivityRemarkDao.class);
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);
    private ContactsActivityRelationDao  contactsActivityRelationDao=SqlSessionUtil.getSqlSession().getMapper(ContactsActivityRelationDao.class);
    private ClueActivityRelationDao clueActivityRelationDao=SqlSessionUtil.getSqlSession().getMapper(ClueActivityRelationDao.class);
    public boolean save(Activity activity) throws AddActivityException {
        int count = activityDao.save(activity);

        if (count != 1) {
            throw new AddActivityException("ActivityServiceImpl中代理执行Dao中的save方法异常");
        } else {
            return true;
        }
    }

    public PaginationVO<Activity> pageList(Map<String, Object> map) {
        //取得total

        int total = activityDao.getTotalByCondition(map);

        //取得活动列表
        List<Activity> dataList = activityDao.getActivityListByCondition(map);


        //将上面的两者封装到vo ，作为返回值返回去

        PaginationVO<Activity> vo = new PaginationVO<Activity>();
        vo.setTotal(total);
        vo.setDataList(dataList);
        return vo;
    }
    //批量删除操作和单个删除操作
    public boolean delete(String[] ids) {
        //因为一条市场活动还对应着x条备注。所以要删除市场活动的时候，要先删除其有联系的备注

        boolean flag = true;
        //查询出需要删除的备注的数量
        int count1 = activityremarkDao.getCountByAids(ids);
        //删除备注，返回受到影响的条数（即实际删除备注的数量）
        int count2 = activityremarkDao.deleteByAids(ids);

        if (count1 != count2) {
            flag = false;
        }

        //删除线索活动关系表中的相关信息
        int count3 = clueActivityRelationDao.getCountByAids(ids);
        int count4= clueActivityRelationDao.deleteByAids(ids);
        if (count3 != count4) {
            flag = false;
        }
        //活动的删除。那么活动与联系人关系的表要删除吗？
        int count5=contactsActivityRelationDao.getCountByAids(ids);
        int count6=contactsActivityRelationDao.deleteByAids(ids);
        if (count5 != count6) {
            flag = false;
        }
        //删除市场活动
        int count7 = activityDao.delete(ids);
        if (count7 != ids.length) {
            flag = false;
        }


        return flag;
    }

    public Map<String, Object> getUserListAndActivity(String id) {
        List<User> uList = userDao.getUserList();

        Activity a = activityDao.getById(id);

        Map<String, Object> map = new HashMap<String, Object>();
        map.put("uList", uList);
        map.put("a", a);

        return map;
    }

    public boolean update(Activity activity) {
        boolean flag = true;
        int count = activityDao.update(activity);

        if (count != 1) {
            flag = false;
        }

        return flag;

    }

    public Activity detail(String id) {
        //这里不能使用上面已经写好的 getUserListAndActivity(String id)中的getById。得到单个活动。
        //因为跳转的详细表单页面的所有者为真实名字。而上面方法得到的确实32位字母。
        //所以这里要自己写新的方法。同过sql语句联合两张表，去得到用户的名字。

        Activity a = activityDao.detail(id);


        return a;
    }

    public List<ActivityRemark> getRemarkListByAid(String activityId) {
        List<ActivityRemark> arList = activityremarkDao.getRemarkListByAid(activityId);

        return arList;
    }

    public boolean deleteRemark(String id) {
        boolean flag = true;
        int count = activityremarkDao.deleteById(id);

        if (count != 1) {
            flag = false;
        }
        return flag;
    }

    public boolean saveRemark(ActivityRemark ar) {

        boolean flag = true;
        int count = activityremarkDao.saveRemark(ar);//这里因为使用dao接口调用了方法，所以要在到中定义方法

        if (count != 1) {
            flag = false;
        }


        return flag;
    }

    public boolean updateRemark(ActivityRemark ar) {
        int count = activityremarkDao.updateRemark(ar);//这里因为使用dao接口调用了方法，所以要在到中定义方法
        boolean flag = true;
        if (count != 1) {
            flag = false;
        }


        return flag;
    }

    public List<Activity> getAcitivityListByClueId(String id) {
        List<Activity> aList=activityDao.getAcitivityListByClueId(id);
        return aList;
    }
}

