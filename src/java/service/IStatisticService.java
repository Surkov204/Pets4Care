/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package service;

import java.util.Map;

/**
 *
 * @author ASUS
 */
public interface IStatisticService {

    Map<String, Double> getDailyRevenue();

    Map<String, Double> getMonthlyRevenue();

    Map<String, Double> getYearlyRevenue();
}
