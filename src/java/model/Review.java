package model;

import java.sql.Timestamp;

public class Review {

    private int    reviewId;
    private int    toyId;
    private int    customerId;
    private int    rating;          // 1-5
    private String comment;
    private Timestamp createdAt;

    /* --------- mở rộng: tên khách hàng (join) --------- */
    private String customerName;

    /* ===== Getter / Setter ===== */
    public int getReviewId()       { return reviewId;      }
    public void setReviewId(int id){ this.reviewId = id;   }

    public int getToyId()          { return toyId;         }
    public void setToyId(int toyId){ this.toyId = toyId;   }

    public int getCustomerId()             { return customerId;          }
    public void setCustomerId(int customerId){ this.customerId = customerId; }

    public int getRating()         { return rating;        }
    public void setRating(int r)   { this.rating = r;      }

    public String getComment()     { return comment;       }
    public void setComment(String c){ this.comment = c;    }

    public Timestamp getCreatedAt(){ return createdAt;     }
    public void setCreatedAt(Timestamp ts){ this.createdAt = ts; }

    public String getCustomerName(){ return customerName;  }
    public void setCustomerName(String n){ this.customerName = n; }
}
