package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.Clue;

import java.util.List;
import java.util.Map;

public interface ClueDao {


    int save(Clue clue);


    Clue detail(String id);

    int getTotalByCondition(Map<String, Object> map);

    List<Clue> getClueListByCondition(Map<String, Object> map);

    Clue getSingleClue(String id);

    int update(Clue clue);

    Clue getById(String clueId);

    int delete(String clueId);

    int deleteNoConvert(String[] ids);

    int getTotal();

    List<Map<String, Object>> getCharts();
}
