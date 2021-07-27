package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.Activity;

import java.util.List;
import java.util.Map;

public interface ActivityDao {


    int save(Activity activity);

    List<Activity> getActivityListByCondition(Map<String, Object> map);

    int getTotalByCondition(Map<String, Object> map);

    int delete(String[] ids);

    Activity getById(String id);

    int update(Activity activity);

    Activity detail(String id);

    List<Activity> getAcitivityListByClueId(String id);


    List<Activity> getActivityByNameAndNotByClueId(Map<String, String> map);

    List<Activity> getActivityByName(String aname);

    List<Activity> getActivityListByCid(String id);

    List<Activity> getActivityListByAids(String[] ids);
}
