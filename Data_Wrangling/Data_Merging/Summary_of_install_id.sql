select 
i.app_id, i.country_id, i.network_id, 
IFNULL(t2.install_id, i.install_id) as install_id, 
IFNULL(profit, 0) as profit, 
IFNULL(complete_revenue, 0) as revenue, 
IFNULL(complete_payouts, 0) as payout, 
IFNULL(count_revenue, 0) as revenue_count, 
IFNULL(count_payout, 0) as payout_count, 
i.device_os_version, 
i.event_date as date_install, 
IFNULL(first_event_date_revenue, i.event_date) as first_event_date_revenue,
IFNULL(last_event_date_revenue, i.event_date) as last_event_date_revenue,
IFNULL(first_event_date_payout, i.event_date) as first_event_date_payout,
IFNULL(last_event_date_payout, i.event_date) as last_event_date_payout
from (
	select 
	IFNULL(t1.revenue_install_id, t1.payout_install_id) as install_id, 
    (t1.complete_revenue - t1.complete_payouts) as profit, 
	t1.complete_revenue, t1.complete_payouts, 
    IFNULL(t1.install_count, 0) as count_revenue, 
    IFNULL(t1.payout_count, 0) as count_payout, 
	first_event_date_revenue,  
    last_event_date_revenue, 
    first_event_date_payout, 
    last_event_date_payout
	from (
		select 
        r.install_id as revenue_install_id, 
        p.install_id as payout_install_id, 
        IFNULL(r.complete_revenue, 0.0) as complete_revenue, 
		IFNULL(p.complete_payouts, 0.0) as complete_payouts, 
        install_count, 
        payout_count, 
		r.first_event_date_revenue,  
        r.last_event_date_revenue, 
        p.first_event_date_payout, 
        p.last_event_date_payout 
        from (
			(SELECT 
            install_id, 
            sum(value_usd) as complete_revenue, 
            count(install_id) as install_count, 
			min(event_date) as first_event_date_revenue, 
            max(event_date) as last_event_date_revenue
			FROM dicegame.revenue group by install_id) as r
			left JOIN  
				(SELECT install_id, 
                sum(value_usd) as complete_payouts, 
                count(install_id) as payout_count,   
                min(event_date) as first_event_date_payout, 
                max(event_date) as last_event_date_payout
                FROM dicegame.payouts group by install_id) as p 
			on r.install_id = p.install_id) 
		union 
			select 
            r.install_id as revenue_install_id, 
            p.install_id as payout_install_id, 
            IFNULL(r.complete_revenue, 0.0) as complete_revenue, 
			IFNULL(p.complete_payouts, 0.0) as complete_payouts, 
            install_count, 
            payout_count, 
            r.first_event_date_revenue,  
            r.last_event_date_revenue, 
            p.first_event_date_payout, 
            p.last_event_date_payout 
            from (
				(SELECT 
                install_id, 
                sum(value_usd) as complete_revenue, 
                count(install_id) as install_count, 
                min(event_date) as first_event_date_revenue, 
                max(event_date) as last_event_date_revenue
                FROM dicegame.revenue group by install_id) as r
			right JOIN  
				(SELECT 
                install_id, 
                sum(value_usd) as complete_payouts, 
                count(install_id) as payout_count,   
                min(event_date) as first_event_date_payout, 
                max(event_date) as last_event_date_payout
                FROM dicegame.payouts group by install_id) as p 
			on r.install_id = p.install_id) 
		) as t1) as t2
	right join installs as i on i.install_id = t2.install_id
   
    order by profit

;