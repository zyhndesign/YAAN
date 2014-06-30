//
//  UILabel+VerticalAlign.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-10-9.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "UILabel+VerticalAlign.h"

@implementation UILabel (VerticalAlign)

-(void)alignTop
{
    int lineSpacing = 6;
    
    CGSize fontSize =[self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth =self.frame.size.width;//expected width of label
    CGSize theStringSize =[self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
    
    int newLinesToPad =(finalHeight - theStringSize.height)/ (fontSize.height + lineSpacing);    
    for(int i=0; i < newLinesToPad; i++)
        self.text =[self.text stringByAppendingString:@"\n "];
    if (self.text != nil)
    {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:lineSpacing];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.text length])];
        //[firstLabelDesc setText:[muDict objectForKey:@"description"]];
        self.attributedText = attributedString;
        
        if (newLinesToPad <= 2)
        {
            self.lineBreakMode = NSLineBreakByTruncatingTail;
        }
    }
   
}

@end


