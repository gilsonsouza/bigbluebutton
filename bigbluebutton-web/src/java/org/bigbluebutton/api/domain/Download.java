package org.bigbluebutton.api.domain;

public class Download {
	private String format;
	private String url;
	private int length;
	private String md5;	
	public Download(String format, String url, String md5, int length) {
		this.format = format;
		this.url = url;
		this.length = length;
		this.md5 = md5;
	}
	public String getFormat() {
		return format;
	}
	public void setFormat(String format) {
		this.format = format;
	}
	public String getUrl() {
		return url;
	}
	public void setUrl(String url) {
		this.url = url;
	}
	public int getLength() {
		return length;
	}
	public void setLength(int length) {
		this.length = length;
	}
	public void setMd5(String md5) {
		this.md5 = md5;
	}
	public String getMd5() {
		return md5;
	}
	
}
