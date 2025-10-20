/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.IStatisticDAO;
import dao.StatisticDAO;
import java.util.Map;

/**
 *
 * @author ASUS
 */
public class StatisticService implements IStatisticService {

    private final IStatisticDAO statisticDAO = new StatisticDAO();

    @Override
    public Map<String, Double> getDailyRevenue() {
        return statisticDAO.getDailyRevenue();
    }

    @Override
    public Map<String, Double> getMonthlyRevenue() {
        return statisticDAO.getMonthlyRevenue();
    }

    @Override
    public Map<String, Double> getYearlyRevenue() {
        return statisticDAO.getYearlyRevenue();
    }
}
