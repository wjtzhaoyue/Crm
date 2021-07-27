package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.vo.PaginationVO;
import com.bjpowernode.crm.workbench.domain.*;

import java.util.List;
import java.util.Map;

public interface ClueService {
    boolean save(Clue clue);

    Clue detail(String id);

    PaginationVO<Clue> pageList(Map<String, Object> map);


    Clue getSingleClue(String id);

    boolean update(Clue clue);

    List<ClueRemark> getRemarkListByCid(String clueId);

    boolean updateRemark(ClueRemark cr);

    boolean deleteRemark(String id);

    boolean saveRemark(ClueRemark cr);

    boolean unbind(String id);

    List<Activity> getActivityByNameAndNotByClueId(Map<String, String> map);

    boolean guanlian(String cid, String[] aids);

    List<Activity> getActivityByName(String aname);

    boolean convert(String clueId, Tran t, String createBy);

    boolean delete(String[] ids);

    Map<String, Object> getCharts();


    // boolean delete(String[] ids);
}
